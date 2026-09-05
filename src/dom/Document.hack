/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam;

use namespace HH\Lib\{C, Str, Vec};

/**
 * The pleasant-to-use methods can be found on Node. You can get a reference to
 * the `<!DOCTYPE html>` node using `getCurrentNode()`. You can query this in
 * many of the ways that `document.*` works in JavaScript.
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
  private bool $frozen = false;

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

    $parent_id = $this->current->getNodeId();

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
    $this->current = $current->getParent($this);
  }

  public function freeze()[write_props]: void {
    $this->ensureMutable(__METHOD__);
    $this->frozen = true;
  }

  public function getByNodeIdx(NodeId $node_id)[]: Node {
    return $this->nodes[node_id_to_int($node_id)];
  }

  public function getCurrentNode()[]: Node {
    return $this->current;
  }

  public function getChildren(NodeId $node_id)[]: vec<Node> {
    return $this->children[$node_id] ?? vec[];
  }

  public function getDescendants(NodeId $node_id)[]: vec<Node> {
    $start = node_id_to_int($node_id) + 1;
    return $this->getLastDescendantId($node_id)
      |> $$ is null
        ? vec[]
        : Vec\slice($this->nodes, $start, node_id_to_int($$) - $start + 1);
  }

  public function getDescendantsAndSelf(NodeId $node_id)[]: vec<Node> {
    $start = node_id_to_int($node_id);
    return $this->getLastDescendantId($node_id)
      |> $$ is null
        ? vec[]
        : Vec\slice($this->nodes, $start, node_id_to_int($$) - $start + 1);
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
      !$this->frozen,
      'You may not invoke %s on a completed document.',
      $method,
    );
  }

  private function getLastDescendantId(NodeId $node_id)[]: ?NodeId {
    $next_id = $node_id;

    do {
      $last_id = $next_id;
      $next_id = C\last($this->children[$last_id] ?? vec[])?->getNodeId();
    } while ($next_id is nonnull);

    return $node_id !== $last_id ? $last_id : null;
  }
}
