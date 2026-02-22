/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\SGMLStream;

final xhp class article extends HtmlAttributes {
  use SGMLStream\ElementWithOpenAndCloseTags;

  const string TAG_NAME = 'article';
}
