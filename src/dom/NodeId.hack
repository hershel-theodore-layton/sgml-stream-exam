/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam;

newtype NodeId as arraykey = int;

function node_id_from_int(int $int)[]: NodeId {
  return $int;
}
