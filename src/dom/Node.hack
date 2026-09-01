/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam;

final class Node {
  public function __construct(private NodeId $id, private NodeKind $kind)[] {}

  public function getId()[]: NodeId {
    return $this->id;
  }
}
