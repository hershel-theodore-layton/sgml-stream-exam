/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\_Private;

use namespace HH\Lib\{C, Regex, Str, Vec};
use namespace HTL\SGMLStreamExam;

type SelectorTest = shape(
  'kind' => string,
  'value' => string,
  ?'operator' => string,
  ?'operand' => string,
  ?'flag' => string,
  ?'selectors' => Selector,
  ?'a' => int,
  ?'b' => int, /*_*/
);

type SelectorPart = shape(
  'combinator' => string,
  'tests' => vec<SelectorTest>, /*_*/
);

final class Selector {
  public function __construct(private vec<vec<SelectorPart>> $selectors)[] {}

  public function matches(
    SGMLStreamExam\Document $doc,
    SGMLStreamExam\Node $node,
    SGMLStreamExam\Node $scope,
  )[]: bool {
    foreach ($this->selectors as $parts) {
      if (self::matchesPart($parts, C\count($parts) - 1, $doc, $node, $scope)) {
        return true;
      }
    }
    return false;
  }

  private static function matchesPart(
    vec<SelectorPart> $parts,
    int $index,
    SGMLStreamExam\Document $doc,
    SGMLStreamExam\Node $node,
    SGMLStreamExam\Node $scope,
  )[]: bool {
    if ($node->getNodeType() !== SGMLStreamExam\Node::ELEMENT_NODE) {
      return false;
    }
    $part = $parts[$index];
    foreach ($part['tests'] as $test) {
      if (!self::matchesTest($test, $doc, $node, $scope)) {
        return false;
      }
    }
    if ($index === 0) {
      return true;
    }

    $combinator = $part['combinator'];
    $sibling = $combinator === '+' || $combinator === '~';
    $candidate = $sibling
      ? $node->getPreviousElementSibling($doc)
      : $node->getParent($doc);
    while (
      $candidate is nonnull &&
      $candidate->getNodeType() === SGMLStreamExam\Node::ELEMENT_NODE
    ) {
      if (self::matchesPart($parts, $index - 1, $doc, $candidate, $scope)) {
        return true;
      }
      if ($combinator === '>' || $combinator === '+') {
        break;
      }
      $candidate = $sibling
        ? $candidate->getPreviousElementSibling($doc)
        : $candidate->getParent($doc);
    }
    return false;
  }

  private static function matchesTest(
    SelectorTest $test,
    SGMLStreamExam\Document $doc,
    SGMLStreamExam\Node $node,
    SGMLStreamExam\Node $scope,
  )[]: bool {
    $value = $test['value'];
    switch ($test['kind']) {
      case 'universal':
        return true;
      case 'type':
        return Str\lowercase($node->getName()) === Str\lowercase($value);
      case 'id':
        return $node->getAttribute('id') === $value;
      case 'class':
        return C\contains($node->getClassList(), $value);
      case 'attribute':
        return self::matchesAttribute($test, $node);
      case 'pseudo':
        return self::matchesPseudo($test, $doc, $node, $scope);
      default:
        invariant_violation('Unknown selector kind: %s', $test['kind']);
    }
  }

  private static function matchesAttribute(
    SelectorTest $test,
    SGMLStreamExam\Node $node,
  )[]: bool {
    $name = Str\lowercase($test['value']);
    $actual = null;
    foreach ($node->getAttributes() as $key => $value) {
      if (Str\lowercase($key) === $name) {
        $actual = $value;
        break;
      }
    }
    if ($actual is null) {
      return false;
    }
    $operator = $test['operator'] ?? '';
    if ($operator === '') {
      return true;
    }
    $expected = $test['operand'] ?? '';
    $flag = $test['flag'] ?? '';
    // HTML's default value case rules; an explicit s flag overrides them.
    $html_insensitive = keyset[
      'accept',
      'accept-charset',
      'align',
      'alink',
      'axis',
      'bgcolor',
      'charset',
      'checked',
      'clear',
      'codetype',
      'color',
      'compact',
      'declare',
      'defer',
      'dir',
      'direction',
      'disabled',
      'enctype',
      'face',
      'frame',
      'hreflang',
      'http-equiv',
      'lang',
      'language',
      'link',
      'media',
      'method',
      'multiple',
      'nohref',
      'noresize',
      'noshade',
      'nowrap',
      'readonly',
      'rel',
      'rev',
      'rules',
      'scope',
      'scrolling',
      'selected',
      'shape',
      'target',
      'text',
      'type',
      'valign',
      'valuetype',
      'vlink',
    ];
    if (
      $flag === 'i' || ($flag === '' && C\contains($html_insensitive, $name))
    ) {
      $actual = Str\lowercase($actual);
      $expected = Str\lowercase($expected);
    }
    switch ($operator) {
      case '=':
        return $actual === $expected;
      case '~=':
        return $expected !== '' &&
          C\contains(Regex\split($actual, re'/[ \t\n\r\f]+/'), $expected);
      case '|=':
        return $actual === $expected || Str\starts_with($actual, $expected.'-');
      case '^=':
        return $expected !== '' && Str\starts_with($actual, $expected);
      case '$=':
        return $expected !== '' && Str\ends_with($actual, $expected);
      case '*=':
        return $expected !== '' && Str\contains($actual, $expected);
      default:
        invariant_violation('Unknown attribute operator: %s', $operator);
    }
  }

  private static function matchesPseudo(
    SelectorTest $test,
    SGMLStreamExam\Document $doc,
    SGMLStreamExam\Node $node,
    SGMLStreamExam\Node $scope,
  )[]: bool {
    $name = $test['value'];
    $selectors = $test['selectors'] ?? null;
    if ($selectors is nonnull) {
      $matches = $selectors->matches($doc, $node, $scope);
      return $name === 'not' ? !$matches : $matches;
    }
    if ($name === 'scope') {
      return $node === $scope;
    }
    if ($name === 'root') {
      return $node->getParent($doc)->getNodeType() ===
        SGMLStreamExam\Node::DOCUMENT_TYPE_NODE;
    }
    if ($name === 'empty') {
      foreach ($node->getChildren($doc) as $child) {
        if (
          $child->getNodeType() === SGMLStreamExam\Node::ELEMENT_NODE ||
          (
            $child->getNodeType() === SGMLStreamExam\Node::TEXT_NODE &&
            $child->getNodeValue($doc) !== ''
          )
        ) {
          return false;
        }
      }
      return true;
    }

    $of_type = Str\ends_with($name, 'of-type');
    $siblings = Vec\filter(
      $node->getSiblingsAndSelf($doc),
      $s ==> $s->getNodeType() === SGMLStreamExam\Node::ELEMENT_NODE &&
        (
          !$of_type ||
          Str\lowercase($s->getName()) === Str\lowercase($node->getName())
        ),
    );
    $index = C\find_key($siblings, $s ==> $s === $node);
    invariant($index is nonnull, 'The element must be among its siblings.');
    $count = C\count($siblings);
    if (Str\starts_with($name, 'first-')) {
      return $index === 0;
    }
    if (Str\starts_with($name, 'last-')) {
      return $index === $count - 1;
    }
    if (Str\starts_with($name, 'only-')) {
      return $count === 1;
    }
    $position =
      Str\starts_with($name, 'nth-last-') ? $count - $index : $index + 1;
    $a = $test['a'] ?? 0;
    $b = $test['b'] ?? 0;
    $difference = $position - $b;
    return $a === 0
      ? $difference === 0
      : $difference % $a === 0 &&
        ($a > 0 ? $difference >= 0 : $difference <= 0);
  }
}
