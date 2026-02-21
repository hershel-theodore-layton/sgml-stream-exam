/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStream, SGMLStreamInterfaces};

final xhp class input extends SGMLStream\RootElement {
  const ctx INITIALIZATION_CTX = [];

  use SGMLStream\ElementWithOpenTagOnly;

  attribute
    enum {'', 'on', 'off'} autocorrect,
    SGMLStreamInterfaces\BooleanAttribute autofocus,
    string class,
    SGMLStreamInterfaces\BooleanAttribute hidden,
    string id,
    int tabindex;

  const string TAG_NAME = 'input';
}
