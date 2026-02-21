/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStream, SGMLStreamInterfaces};
use namespace HH\Asio;

final xhp class Asynchronous extends SGMLStream\AsynchronousElement {
  use SGMLStream\IgnoreSuccessorFlow;

  <<__Override>>
  protected async function renderAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow>
      $_descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  )[defaults]: Awaitable<SGMLStreamInterfaces\Streamable> {
    await Asio\later();
    return <div class="async">{$this->getChildren()}</div>;
  }
}
