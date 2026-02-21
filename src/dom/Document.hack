/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam;

use namespace HH\Lib\Str;

final class Document {
  private vec<Node> $nodesById;

  public function __construct(private Node $rootNode, private string $text)[] {
    $this->nodesById = vec($this->rootNode->traverse());

    foreach ($this->nodesById as $i => $e) {
      invariant(
        $e->getNodeId() === $i,
        'Invalid tree order, expected %d, got %d',
        $i,
        $e->getNodeId(),
      );
    }
  }

  public function getElementById(string $id)[]: ?Node {
    return $this->rootNode->getElementById($id);
  }

  public function getElementsByClassname(string $classname)[]: vec<Node> {
    return $this->rootNode->getElementsByClassname($classname);
  }

  public function getNodeByIdx(int $node_id)[]: Node {
    return $this->nodesById[$node_id];
  }

  public function getRootElement()[]: Node {
    return $this->rootNode;
  }

  public function getText()[]: string {
    return $this->text;
  }

  public function sliceTextRange(int $start, int $end)[]: string {
    return Str\slice($this->text, $start, $end - $start);
  }
}
