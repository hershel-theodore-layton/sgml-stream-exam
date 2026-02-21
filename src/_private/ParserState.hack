/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\_Private;

enum ParserState: int {
  DATA_STATE = 0;
  COMMENT_STATE = 1;
}
