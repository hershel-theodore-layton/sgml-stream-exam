/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam;

enum NodeKind: int {
  DOCUMENT_ROOT = 0;
  COMMENT = 1;
  TEXT = 2;
  TAG = 3;
}
