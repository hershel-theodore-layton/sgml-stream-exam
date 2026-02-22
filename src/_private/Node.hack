/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\_Private;

use namespace HH\Lib\{C, Vec};
use namespace HTL\SGMLStreamExam;

final class Node implements SGMLStreamExam\Node {
  private vec<Node> $children = vec[];

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

  public function append(Node $node)[write_props]: void {
    $this->children[] = $node;
  }

  public function getAttribute(string $name)[]: ?string {
    return $this->attributes[$name] ?? null;
  }

  public function getAttributes()[]: dict<string, string> {
    return $this->attributes;
  }

  public function getChildren()[]: vec<Node> {
    return $this->children;
  }

  public function getClassName()[]: string {
    return $this->getAttribute('class') ?? '';
  }

  public function getElementById(string $id)[]: ?Node {
    return C\find($this->traverse(), $x ==> $x->getId() === $id);
  }

  public function getElementByIdx(string $id)[]: Node {
    $element = $this->getElementById($id);
    invariant(
      $element is nonnull,
      'Element with the id "%s" was not found.',
      $id,
    );
    return $element;
  }

  public function getElementsByClassname(string $classname)[]: vec<Node> {
    return
      Vec\filter($this->traverse(), $x ==> $x->getClassName() === $classname);
  }

  public function getFirstChild()[]: ?Node {
    return C\first($this->children);
  }

  public function getFirstChildx()[]: Node {
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

  public function getLastChild()[]: ?Node {
    return C\last($this->children);
  }

  public function getLastChildx()[]: Node {
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

  public function getNodeId()[]: int {
    return $this->nodeId;
  }

  public function getOuterHTML(SGMLStreamExam\Document $document)[]: string {
    return $document->sliceTextRange($this->startIndex, $this->endIndex);
  }

  public function getParent(
    SGMLStreamExam\Document $document,
  )[]: SGMLStreamExam\Node {
    return $document->getNodeByIdx($this->parentNodeId);
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

  public function traverse()[]: Traversable<Node> {
    yield $this;

    foreach ($this->children as $child) {
      foreach ($child->traverse() as $yield_from) {
        yield $yield_from;
      }
    }
  }

  public function toUnitTestDump(
    SGMLStreamExam\Document $document,
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
