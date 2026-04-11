/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\_Private;

use namespace HH\Lib\{C, Keyset, Regex, Str, Vec};
use namespace HTL\SGMLStreamExam;

final class Node__ implements SGMLStreamExam\Node {
  private vec<Node__> $children = vec[];

  public function __construct(
    private int $startIndex,
    private int $endIndex,
    private string $name,
    private dict<string, string> $attributes,
    private int $nodeId,
    private int $parentNodeId,
  )[] {}

  public static function createComment(int $start_index)[]: this {
    return new static($start_index, -1, static::COMMENT_NAME, dict[], -1, -1);
  }

  public static function createElement(
    int $start_index,
    string $name,
    dict<string, string> $attributes,
  )[]: this {
    return new static($start_index, -1, $name, $attributes, -1, -1);
  }

  public static function createTextNode(int $start_index)[]: this {
    return new static($start_index, -1, static::TXTNODE_NAME, dict[], -1, -1);
  }

  public function append(Node__ $node)[write_props]: void {
    $this->children[] = $node;
  }

  public function contains(SGMLStreamExam\Node $other)[]: bool {
    foreach ($this->traverse() as $el) {
      if ($el === $other) {
        return true;
      }
    }

    return false;
  }

  public function getAncestors(
    SGMLStreamExam\Document__ $document,
  )[]: vec<SGMLStreamExam\Node> {
    $prev = $this;
    $out = vec[];

    for (; ; ) {
      $next = $prev->getParent($document);
      if ($prev === $next) {
        return $out;
      }

      $out[] = $next;
      $prev = $next;
    }
  }

  public function getAttribute(string $name)[]: ?string {
    return $this->attributes[$name] ?? null;
  }

  public function getAttributes()[]: dict<string, string> {
    return $this->attributes;
  }

  public function getChildElementCount()[]: int {
    $count = 0;

    foreach ($this->children as $child) {
      if ($child->isElement()) {
        $count++;
      }
    }

    return $count;
  }

  public function getChildren()[]: vec<Node__> {
    return $this->children;
  }

  public function getClassList()[]: keyset<string> {
    return Regex\split($this->getClassName(), re'/\s+/')
      |> Keyset\filter($$, $x ==> $x !== '');
  }

  public function getClassName()[]: string {
    return $this->getAttribute('class') ?? '';
  }

  public function getElementById(string $id)[]: ?Node__ {
    return C\find($this->traverseDescendants(), $x ==> $x->getId() === $id);
  }

  public function getElementByIdx(string $id)[]: Node__ {
    $element = $this->getElementById($id);
    invariant(
      $element is nonnull,
      'Element with the id "%s" was not found.',
      $id,
    );
    return $element;
  }

  public function getElementsByClassName(string $class_name)[]: vec<Node__> {
    return Vec\filter(
      $this->traverseDescendants(),
      $x ==> C\contains_key($x->getClassList(), $class_name),
    );
  }

  public function getFirstChild()[]: ?Node__ {
    return C\first($this->children);
  }

  public function getFirstChildx()[]: Node__ {
    $first_child = $this->getFirstChild();
    invariant(
      $first_child is nonnull,
      'May not call getFirstChildx on a Node with zero children.',
    );
    return $first_child;
  }

  public function getId()[]: string {
    return $this->getAttribute('id') ?? '';
  }

  public function getInnerHTML(SGMLStreamExam\Document__ $document)[]: string {
    return Vec\map($this->children, $c ==> $c->getOuterHTML($document))
      |> Str\join($$, '');
  }

  public function getLastChild()[]: ?Node__ {
    return C\last($this->children);
  }

  public function getLastChildx()[]: Node__ {
    $last_child = $this->getLastChild();
    invariant(
      $last_child is nonnull,
      'May not call getLastChildx on a Node with zero children.',
    );
    return $last_child;
  }

  public function getName()[]: string {
    return $this->name;
  }

  public function getNextSibling(
    SGMLStreamExam\Document__ $document,
  )[]: ?SGMLStreamExam\Node {
    $generation = $this->getSiblingsAndSelf($document);
    return $generation[index_ofx($generation, $this) + 1] ?? null;
  }

  public function getNodeId()[]: int {
    return $this->nodeId;
  }

  public function getNodeType()[]: int {
    switch ($this->name) {
      case static::COMMENT_NAME:
        return static::COMMENT_NODE;
      case static::DOCTYPE_NAME:
        return static::DOCTYPE_NODE;
      case static::TXTNODE_NAME:
        return static::TEXT_NODE;
      default:
        return static::ELEMENT_NODE;
    }
  }

  public function getNodeValue(SGMLStreamExam\Document__ $document)[]: ?string {
    switch ($this->getNodeType()) {
      case static::TEXT_NODE:
        return $this->getOuterHTML($document);
      case static::COMMENT_NODE:
        return $this->getOuterHTML($document)
          |> Str\strip_prefix($$, '<!--')
          |> Str\strip_suffix($$, '-->');
      default:
        return null;
    }
  }

  public function getOuterHTML(SGMLStreamExam\Document__ $document)[]: string {
    return $document->sliceTextRange($this->startIndex, $this->endIndex);
  }

  public function getParent(
    SGMLStreamExam\Document__ $document,
  )[]: SGMLStreamExam\Node {
    return $document->getNodeByIdx($this->parentNodeId);
  }

  public function getPreviousSibling(
    SGMLStreamExam\Document__ $document,
  )[]: ?SGMLStreamExam\Node {
    $generation = $this->getSiblingsAndSelf($document);
    return $generation[index_ofx($generation, $this) - 1] ?? null;
  }

  public function getSiblingsAndSelf(
    SGMLStreamExam\Document__ $document,
  )[]: vec<SGMLStreamExam\Node> {
    if ($this->name === Node__::DOCTYPE_NAME) {
      return vec[$this];
    }

    return $this->getParent($document)->getChildren();
  }

  public function getTextContent(
    SGMLStreamExam\Document__ $document,
  )[]: string {
    return Vec\filter(
      $this->traverse(),
      $x ==> $x->getNodeType() === static::TEXT_NODE,
    )
      |> Vec\map($$, $x ==> $x->getOuterHTML($document))
      |> Str\join($$, '');
  }

  public function isElement()[]: bool {
    return $this->getNodeType() === static::ELEMENT_NODE;
  }

  public function setEndIndex(int $end_index)[write_props]: void {
    $this->endIndex = $end_index;
  }

  public function setNodeId(int $node_id)[write_props]: void {
    $this->nodeId = $node_id;
  }

  public function setParentNodeId(int $node_id)[write_props]: void {
    $this->parentNodeId = $node_id;
  }

  public function traverse()[]: Traversable<Node__> {
    yield $this;

    foreach ($this->children as $child) {
      foreach ($child->traverse() as $yield_from) {
        yield $yield_from;
      }
    }
  }

  public function traverseDescendants()[]: Traversable<Node__> {
    foreach ($this->children as $child) {
      foreach ($child->traverse() as $yield_from) {
        yield $yield_from;
      }
    }
  }

  public function toUnitTestDump(
    SGMLStreamExam\Document__ $document,
  )[]: this::UnitTestDump {
    return shape(
      'outerHTML' => $this->getOuterHTML($document),
      'name' => $this->name,
      'attributes' => $this->attributes,
      'children' =>
        Vec\map($this->children, $c ==> $c->toUnitTestDump($document)),
    );
  }
}
