/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStream, SGMLStreamInterfaces};

final xhp class Simple extends SGMLStream\SimpleElement {
  use SGMLStream\IgnoreSuccessorFlow;

  <<__Override>>
  protected function render(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow>
      $_descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  )[defaults]: SGMLStreamInterfaces\Streamable {
    return <div class="simple">{$this->getChildren()}</div>;
  }
}
