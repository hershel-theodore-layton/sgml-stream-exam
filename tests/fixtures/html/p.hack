/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\SGMLStream;

final xhp class p extends HtmlAttributes {
  use SGMLStream\ElementWithOpenAndCloseTags;

  const string TAG_NAME = 'p';
}
