/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam;

final class Node {
  const string COMMENT = '!COMMENT';
  const string DOCUMENT_ROOT = '!DOCUMENT_ROOT';
  const string TEXT = '!TEXT';

  public function __construct(
    private NodeId $id,
    private NodeId $parentId,
    private string $tagName,
    private int $startByteRange,
  )[] {}

  public function getId()[]: NodeId {
    return $this->id;
  }

  public function getTagName()[]: string {
    return $this->tagName;
  }

  public function getParentx(Document $document)[]: Node {
    return $document->getByIdx($this->parentId);
  }
}
