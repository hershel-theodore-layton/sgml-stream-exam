/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\_Private;

use namespace HH\Lib\Str;
use namespace HTL\SGMLStreamExam;
use function chr, ord;

type SelectorToken =
  shape('kind' => string, 'value' => string, 'adjacent' => bool /*_*/);

final class SelectorTokenizer {
  public static function tokenize(string $source)[]: vec<SelectorToken> {
    $source = Str\replace($source, "\r\n", "\n")
      |> Str\replace($$, "\r", "\n")
      |> Str\replace($$, "\f", "\n")
      |> Str\replace($$, "\0", "\u{fffd}");
    $tokens = vec[];
    $previous_end = 0;
    $length = Str\length($source);
    for ($i = 0; $i < $length; ) {
      $start = $i;
      $token = null;
      $char = $source[$i];
      if (Str\slice($source, $i, 2) === '/*') {
        $end = Str\search($source, '*/', $i + 2);
        if ($end is null) {
          throw new SGMLStreamExam\InvalidSelectorException(
            'Unterminated selector comment.',
          );
        }
        $i = $end + 2;
      } else if (self::isWhitespace($char)) {
        do {
          $i++;
        } while ($i < $length && self::isWhitespace($source[$i]));
        $token = shape('kind' => 'space', 'value' => ' ');
      } else if ($char === '"' || $char === "'") {
        $quote = $char;
        $value = '';
        $i++;
        while ($i < $length && $source[$i] !== $quote) {
          if ($source[$i] === "\n") {
            throw new SGMLStreamExam\InvalidSelectorException(
              'Unescaped newline in selector string.',
            );
          }
          if ($source[$i] === '\\') {
            if (($source[$i + 1] ?? '') === "\n") {
              $i += 2;
            } else {
              $value .= self::consumeEscape($source, inout $i);
            }
          } else {
            $value .= $source[$i];
            $i++;
          }
        }
        if ($i === $length) {
          throw new SGMLStreamExam\InvalidSelectorException(
            'Unterminated selector string.',
          );
        }
        $i++;
        $token = shape('kind' => 'string', 'value' => $value);
      } else if (self::startsIdentifier($source, $i)) {
        $value = '';
        while ($i < $length) {
          $char = $source[$i];
          if ($char === '\\') {
            $value .= self::consumeEscape($source, inout $i);
          } else if (
            self::isNameStart($char) ||
            $char === '-' ||
            Str\contains('0123456789', $char)
          ) {
            $value .= $char;
            $i++;
          } else {
            break;
          }
        }
        $token = shape('kind' => 'ident', 'value' => $value);
      } else {
        $token = shape('kind' => 'symbol', 'value' => $char);
        $i++;
      }
      if ($token is nonnull) {
        $token['adjacent'] = $start === $previous_end;
        $tokens[] = $token;
        $previous_end = $i;
      }
    }
    return $tokens;
  }

  private static function isWhitespace(string $char)[]: bool {
    return $char !== '' && Str\contains(" \t\n", $char);
  }

  private static function isNameStart(string $char)[]: bool {
    return $char !== '' &&
      (
        ord($char) >= 128 ||
        Str\contains(
          'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_',
          $char,
        )
      );
  }

  private static function startsIdentifier(string $source, int $i)[]: bool {
    $char = $source[$i] ?? '';
    if ($char === '-') {
      $i++;
      $char = $source[$i] ?? '';
      if ($char === '-') {
        return true;
      }
    }
    return self::isNameStart($char) ||
      (
        $char === '\\' &&
        ($source[$i + 1] ?? '') !== '' &&
        $source[$i + 1] !== "\n"
      );
  }

  private static function consumeEscape(
    string $source,
    inout int $i,
  )[]: string {
    $i++;
    $char = $source[$i] ?? '';
    if ($char === '' || $char === "\n") {
      throw
        new SGMLStreamExam\InvalidSelectorException('Invalid selector escape.');
    }
    $codepoint = 0;
    $digits = 0;
    while ($digits < 6 && $i < Str\length($source)) {
      $digit = Str\search('0123456789abcdef', Str\lowercase($source[$i]));
      if ($digit is null) {
        break;
      }
      $codepoint = $codepoint * 16 + $digit;
      $digits++;
      $i++;
    }
    if ($digits === 0) {
      $i++;
      return $char;
    }
    if (self::isWhitespace($source[$i] ?? '')) {
      $i++;
    }
    if (
      $codepoint === 0 ||
      $codepoint > 0x10ffff ||
      ($codepoint >= 0xd800 && $codepoint <= 0xdfff)
    ) {
      return "\u{fffd}";
    }
    if ($codepoint < 0x80) {
      return chr($codepoint);
    }
    if ($codepoint < 0x800) {
      return chr(0xc0 | ($codepoint >> 6)).chr(0x80 | ($codepoint & 0x3f));
    }
    if ($codepoint < 0x10000) {
      return chr(0xe0 | ($codepoint >> 12)).
        chr(0x80 | (($codepoint >> 6) & 0x3f)).
        chr(0x80 | ($codepoint & 0x3f));
    }
    return chr(0xf0 | ($codepoint >> 18)).
      chr(0x80 | (($codepoint >> 12) & 0x3f)).
      chr(0x80 | (($codepoint >> 6) & 0x3f)).
      chr(0x80 | ($codepoint & 0x3f));
  }
}
