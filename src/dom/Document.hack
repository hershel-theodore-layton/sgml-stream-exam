/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam;

final class Document {
  private vec<Node> $nodes;
  private dict<NodeId, vec<Node>> $children = dict[];

  public function __construct()[] {
    $this->nodes = vec[new Node(node_id_from_int(0), NodeKind::DOCUMENT_ROOT)];
  }

  public function addNode(Node $parent, Node $self)[write_props]: void {
    $this->nodes[] = $self;
    $this->children[$parent->getId()] ??= vec[];
    $this->children[$parent->getId()][] = $self;
  }
}
