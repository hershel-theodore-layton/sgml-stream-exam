/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStream, SGMLStreamInterfaces};

final xhp class div extends SGMLStream\RootElement {
  const ctx INITIALIZATION_CTX = [];

  use SGMLStream\ElementWithOpenAndCloseTags;

  attribute
    enum {'', 'on', 'off'} autocorrect,
    SGMLStreamInterfaces\BooleanAttribute autofocus,
    string class,
    SGMLStreamInterfaces\BooleanAttribute hidden,
    string id,
    int tabindex,
    string title;

  const string TAG_NAME = 'div';
}
