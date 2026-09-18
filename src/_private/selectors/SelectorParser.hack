/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\_Private;

use namespace HH\Lib\{C, Regex, Str, Vec};
use namespace HTL\SGMLStreamExam;

final class SelectorParser {
  public static function parse(string $source)[]: Selector {
    return self::parseList(SelectorTokenizer::tokenize($source), false, 0);
  }

  private static function parseList(
    vec<SelectorToken> $tokens,
    bool $forgiving,
    int $depth,
  )[]: Selector {
    if ($depth > 64) {
      throw new SGMLStreamExam\InvalidSelectorException(
        'Selector nesting exceeds 64 levels.',
      );
    }
    $selectors = vec[];
    $start = 0;
    $stack = vec[];
    $length = C\count($tokens);
    for ($i = 0; $i <= $length; $i++) {
      $token = $tokens[$i] ??
        shape('kind' => 'symbol', 'value' => ',', 'adjacent' => true);
      if ($token['kind'] !== 'symbol') {
        continue;
      }
      $value = $token['value'];
      if ($value === '(' || $value === '[') {
        $stack[] = $value === '(' ? ')' : ']';
      } else if ($value === ')' || $value === ']') {
        if (C\last($stack) !== $value) {
          throw new SGMLStreamExam\InvalidSelectorException(
            'Unbalanced selector delimiters.',
          );
        }
        $stack = Vec\slice($stack, 0, C\count($stack) - 1);
      } else if ($value === ',' && C\is_empty($stack)) {
        try {
          $selectors[] =
            self::parseComplex(Vec\slice($tokens, $start, $i - $start), $depth);
        } catch (SGMLStreamExam\InvalidSelectorException $error) {
          if (!$forgiving) {
            throw $error;
          }
        }
        $start = $i + 1;
      }
    }
    if (!C\is_empty($stack)) {
      throw new SGMLStreamExam\InvalidSelectorException(
        'Unbalanced selector delimiters.',
      );
    }
    return new Selector($selectors);
  }

  private static function parseComplex(
    vec<SelectorToken> $tokens,
    int $depth,
  )[]: vec<SelectorPart> {
    $i = 0;
    self::skipSpaces($tokens, inout $i);
    $parts = vec[];
    $combinator = '';
    for (; ; ) {
      $tests = vec[];
      if (self::isSymbol($tokens, $i, '*')) {
        $tests[] = shape('kind' => 'universal', 'value' => '');
        $i++;
      } else if (($tokens[$i]['kind'] ?? '') === 'ident') {
        $tests[] = shape('kind' => 'type', 'value' => $tokens[$i]['value']);
        $i++;
      }
      for (; ; ) {
        if (
          self::isSymbol($tokens, $i, '#') || self::isSymbol($tokens, $i, '.')
        ) {
          $kind = $tokens[$i]['value'] === '#' ? 'id' : 'class';
          $i++;
          if ($kind === 'id' && !($tokens[$i]['adjacent'] ?? false)) {
            throw new SGMLStreamExam\InvalidSelectorException(
              'An ID selector must be a single hash token.',
            );
          }
          $tests[] = shape(
            'kind' => $kind,
            'value' => self::identifier($tokens, inout $i),
          );
        } else if (self::isSymbol($tokens, $i, '[')) {
          $tests[] = self::attribute($tokens, inout $i);
        } else if (self::isSymbol($tokens, $i, ':')) {
          $tests[] = self::pseudo($tokens, inout $i, $depth);
        } else {
          break;
        }
      }
      if (C\is_empty($tests)) {
        throw new SGMLStreamExam\InvalidSelectorException(
          'Expected a selector after a comma or combinator.',
        );
      }
      $parts[] = shape('combinator' => $combinator, 'tests' => $tests);
      $had_space = self::skipSpaces($tokens, inout $i);
      if ($i === C\count($tokens)) {
        return $parts;
      }
      if (
        self::isSymbol($tokens, $i, '>') ||
        self::isSymbol($tokens, $i, '+') ||
        self::isSymbol($tokens, $i, '~')
      ) {
        $combinator = $tokens[$i]['value'];
        $i++;
        self::skipSpaces($tokens, inout $i);
      } else if ($had_space) {
        $combinator = ' ';
      } else {
        throw new SGMLStreamExam\InvalidSelectorException(
          'Unexpected selector token: '.$tokens[$i]['value'],
        );
      }
    }
  }

  private static function attribute(
    vec<SelectorToken> $tokens,
    inout int $i,
  )[]: SelectorTest {
    $i++;
    self::skipSpaces($tokens, inout $i);
    $name = self::identifier($tokens, inout $i);
    self::skipSpaces($tokens, inout $i);
    if (self::isSymbol($tokens, $i, ']')) {
      $i++;
      return shape('kind' => 'attribute', 'value' => $name);
    }
    $operator = '';
    if (
      ($tokens[$i]['kind'] ?? '') === 'symbol' &&
      C\contains(keyset['~', '|', '^', '$', '*'], $tokens[$i]['value'])
    ) {
      $operator = $tokens[$i]['value'];
      $i++;
    }
    self::requireSymbol($tokens, inout $i, '=');
    $operator .= '=';
    self::skipSpaces($tokens, inout $i);
    if (($tokens[$i]['kind'] ?? '') === 'string') {
      $value = $tokens[$i]['value'];
      $i++;
    } else {
      $value = self::identifier($tokens, inout $i);
    }
    self::skipSpaces($tokens, inout $i);
    $flag = '';
    if (($tokens[$i]['kind'] ?? '') === 'ident') {
      $flag = Str\lowercase(self::identifier($tokens, inout $i));
      if ($flag !== 'i' && $flag !== 's') {
        throw new SGMLStreamExam\InvalidSelectorException(
          'Unknown attribute selector flag: '.$flag,
        );
      }
      self::skipSpaces($tokens, inout $i);
    }
    self::requireSymbol($tokens, inout $i, ']');
    return shape(
      'kind' => 'attribute',
      'value' => $name,
      'operator' => $operator,
      'operand' => $value,
      'flag' => $flag,
    );
  }

  private static function pseudo(
    vec<SelectorToken> $tokens,
    inout int $i,
    int $depth,
  )[]: SelectorTest {
    $i++;
    $name = Str\lowercase(self::identifier($tokens, inout $i));
    if (self::isSymbol($tokens, $i, '(') && $tokens[$i]['adjacent']) {
      $i++;
      $start = $i;
      $nesting = 1;
      while ($i < C\count($tokens)) {
        if (self::isSymbol($tokens, $i, '(')) {
          $nesting++;
        } else if (self::isSymbol($tokens, $i, ')')) {
          $nesting--;
          if ($nesting === 0) {
            break;
          }
        }
        $i++;
      }
      $arguments = Vec\slice($tokens, $start, $i - $start);
      self::requireSymbol($tokens, inout $i, ')');
      if (C\contains(keyset['not', 'is', 'where'], $name)) {
        return shape(
          'kind' => 'pseudo',
          'value' => $name,
          'selectors' =>
            self::parseList($arguments, $name !== 'not', $depth + 1),
        );
      }
      if (
        C\contains(
          keyset[
            'nth-child',
            'nth-last-child',
            'nth-of-type',
            'nth-last-of-type',
          ],
          $name,
        )
      ) {
        list($a, $b) = self::nth($arguments);
        return
          shape('kind' => 'pseudo', 'value' => $name, 'a' => $a, 'b' => $b);
      }
    } else if (
      C\contains(
        keyset[
          'scope',
          'root',
          'empty',
          'first-child',
          'last-child',
          'only-child',
          'first-of-type',
          'last-of-type',
          'only-of-type',
        ],
        $name,
      )
    ) {
      return shape('kind' => 'pseudo', 'value' => $name);
    }
    throw new SGMLStreamExam\InvalidSelectorException(
      'Unsupported or invalid pseudo-class: '.$name,
    );
  }

  private static function nth(vec<SelectorToken> $tokens)[]: (int, int) {
    foreach ($tokens as $token) {
      if (
        $token['kind'] === 'string' ||
        (
          $token['kind'] === 'ident' &&
          Regex\first_match(
            $token['value'],
            re'/^(?:odd|even|-?n(?:-[0-9]*)?)$/iD',
          ) is null
        )
      ) {
        throw new SGMLStreamExam\InvalidSelectorException(
          'Invalid nth expression.',
        );
      }
    }
    $text = Vec\map($tokens, $t ==> ($t['adjacent'] ? '' : ' ').$t['value'])
      |> Str\join($$, '')
      |> Str\trim($$)
      |> Str\lowercase($$);
    if ($text === 'odd') {
      return tuple(2, 1);
    }
    if ($text === 'even') {
      return tuple(2, 0);
    }
    if (Regex\first_match($text, re'/^[+-]?[0-9]+$/D') is nonnull) {
      return tuple(0, self::integer($text));
    }
    $match =
      Regex\first_match($text, re'/^([+-]?[0-9]*)n(?: *([+-]) *([0-9]+))?$/D');
    if ($match is null) {
      throw
        new SGMLStreamExam\InvalidSelectorException('Invalid nth expression.');
    }
    $coefficient = $match[1];
    $a = $coefficient === '' || $coefficient === '+'
      ? 1
      : ($coefficient === '-' ? -1 : self::integer($coefficient));
    $b = self::integer(($match[2] ?? '').($match[3] ?? '0'));
    return tuple($a, $b);
  }

  private static function integer(string $text)[]: int {
    // Bound arithmetic so position - b and modulo cannot overflow.
    if (Str\length($text) > 10) {
      throw new SGMLStreamExam\InvalidSelectorException(
        'Nth integer is too large.',
      );
    }
    return (int)$text;
  }

  private static function identifier(
    vec<SelectorToken> $tokens,
    inout int $i,
  )[]: string {
    if (($tokens[$i]['kind'] ?? '') !== 'ident') {
      throw new SGMLStreamExam\InvalidSelectorException(
        'Expected a CSS identifier.',
      );
    }
    $value = $tokens[$i]['value'];
    $i++;
    return $value;
  }

  private static function isSymbol(
    vec<SelectorToken> $tokens,
    int $i,
    string $symbol,
  )[]: bool {
    return ($tokens[$i]['kind'] ?? '') === 'symbol' &&
      $tokens[$i]['value'] === $symbol;
  }

  private static function requireSymbol(
    vec<SelectorToken> $tokens,
    inout int $i,
    string $symbol,
  )[]: void {
    if (!self::isSymbol($tokens, $i, $symbol)) {
      throw
        new SGMLStreamExam\InvalidSelectorException('Expected '.$symbol.'.');
    }
    $i++;
  }

  private static function skipSpaces(
    vec<SelectorToken> $tokens,
    inout int $i,
  )[]: bool {
    $start = $i;
    while (($tokens[$i]['kind'] ?? '') === 'space') {
      $i++;
    }
    return $i !== $start;
  }
}
