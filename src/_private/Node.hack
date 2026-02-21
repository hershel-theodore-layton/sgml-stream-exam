/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\_Private;

use namespace HH\Lib\Vec;
use namespace HTL\SGMLStreamExam;

final class Node implements SGMLStreamExam\Node {
  const string COMMENT_NAME = '!COMMENT';
  const string DOCTYPE_NAME = '!DOCTYPE';
  const string TXTNODE_NAME = '!TXTNODE';

  private vec<Node> $children = vec[];
  private int $endIndex = -1;

  public function __construct(
    private int $startIndex,
    private string $name,
    private dict<string, string> $attributes,
  )[] {}

  public function append(Node $node)[write_props]: void {
    $this->children[] = $node;
  }

  public function getAttributes()[]: dict<string, string> {
    return $this->attributes;
  }

  public function getChildren()[]: vec<Node> {
    return $this->children;
  }

  public function getName()[]: string {
    return $this->name;
  }

  public function getOuterHTML(SGMLStreamExam\Document $document)[]: string {
    return $document->sliceTextRange($this->startIndex, $this->endIndex);
  }

  public function setEndIndex(int $end_index)[write_props]: void {
    $this->endIndex = $end_index;
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
