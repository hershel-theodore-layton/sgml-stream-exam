/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStream, SGMLStreamInterfaces};

final xhp class Dissolve extends SGMLStream\DissolvableElement {
  <<__Override>>
  protected function render(
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  )[defaults]: SGMLStreamInterfaces\Streamable {
    return <div class="dissolve">{$this->getChildren()}</div>;
  }
}
