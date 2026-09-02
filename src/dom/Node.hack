/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam;

final class Node {
  const string COMMENT = '!COMMENT';
  const string DOCTYPE = '!DOCTYPE';
  const string TXTNODE = '!TXTNODE';

  public function __construct(
    private NodeId $id,
    private NodeId $parentId,
    private string $tagName,
    private dict<string, string> $attributes,
    private int $startByteRange,
    private int $endByteRange = -1,
  )[] {}

  public function getAttributes()[]: dict<string, string> {
    return $this->attributes;
  }

  public function getChildren(Document $doc)[]: vec<Node> {
    return $doc->getChildren($this->id);
  }

  public function getId()[]: NodeId {
    return $this->id;
  }

  public function getTagName()[]: string {
    return $this->tagName;
  }

  public function getOuterHtml(Document $doc)[]: string {
    return $doc->sliceBytes($this->startByteRange, $this->endByteRange);
  }

  public function getParentx(Document $document)[]: Node {
    return $document->getByIdx($this->parentId);
  }

  public function setEndByteRange(int $end_byte_range)[write_props]: void {
    $this->endByteRange = $end_byte_range;
  }
}
