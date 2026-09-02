/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam;

use namespace HH\Lib\{C, Str};

/**
 * The pleasant to use methods can be found on Node. You can get a reference to
 * the `<!DOCTYPE html>` node using `getCurrentNode()`. You can query this in
 * many of the ways that `document.*` works in Javascript.
 *
 * If you insist on using the Document methods directly, a note of caution.
 * Methods annotated with `[write_props]` are meant to be used during parsing.
 * You should not call these methods in your tests. Doing so will result in
 * an InvariantViolationException.
 */
final class Document {
  private Node $current;
  private string $documentText = '<!DOCTYPE html>';
  private vec<Node> $nodes;
  private dict<NodeId, vec<Node>> $children = dict[];

  public function __construct()[] {
    $node = new Node(
      node_id_from_int(0),
      node_id_from_int(0),
      Node::DOCTYPE,
      dict[],
      0,
      Str\length($this->documentText),
    );
    $this->nodes = vec[$node];
    $this->current = $node;
  }

  public function addNode(
    shape(
      'attributes' => dict<string, string>,
      'tag_name' => string,
      'text' => string, /*_*/
    ) $arg,
  )[write_props]: void {
    $this->ensureMutable(__METHOD__);

    $parent_id = $this->current->getId();

    $node = new Node(
      node_id_from_int(C\count($this->nodes)),
      $parent_id,
      $arg['tag_name'],
      $arg['attributes'],
      Str\length($this->documentText),
    );

    $this->nodes[] = $node;
    $this->current = $node;
    $this->children[$parent_id] ??= vec[];
    $this->children[$parent_id][] = $node;

    $this->pushHtmlSource($arg['text']);
  }

  public function closeNode()[write_props]: void {
    $this->ensureMutable(__METHOD__);
    $current = $this->current;
    $current->setEndByteRange(Str\length($this->documentText));
    $this->current = $current->getParentx($this);
  }

  public function getByIdx(NodeId $id)[]: Node {
    return $this->nodes[node_id_to_int($id)];
  }

  public function getCurrentNode()[]: Node {
    return $this->current;
  }

  public function getChildren(NodeId $node_id)[]: vec<Node> {
    return $this->children[$node_id] ?? vec[];
  }

  public function sliceBytes(int $start, int $end)[]: string {
    return Str\slice($this->documentText, $start, $end - $start);
  }

  public function pushHtmlSource(string $bytes)[write_props]: void {
    $this->ensureMutable(__METHOD__);
    $this->documentText .= $bytes;
  }

  private function ensureMutable(string $method)[]: void {
    invariant(
      $this->current->getId() !== 0 || C\count($this->nodes) === 1,
      'You may not invoke %s on a completed document.',
      $method,
    );
  }
}
