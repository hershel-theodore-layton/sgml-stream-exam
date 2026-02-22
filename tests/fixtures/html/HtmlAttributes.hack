/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStream, SGMLStreamInterfaces};

abstract xhp class HtmlAttributes extends SGMLStream\RootElement {
  const ctx INITIALIZATION_CTX = [];

  attribute
    enum {'', 'on', 'off'} autocorrect,
    SGMLStreamInterfaces\BooleanAttribute autofocus,
    string class,
    SGMLStreamInterfaces\BooleanAttribute hidden,
    string id,
    int tabindex,
    string title;
}
