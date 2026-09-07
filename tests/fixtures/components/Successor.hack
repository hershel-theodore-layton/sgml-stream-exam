/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HH\Asio;
use namespace HTL\{SGMLStream, SGMLStreamInterfaces};

final xhp class Successor
  extends SGMLStream\AsynchronousElementWithSuccessorFlow {

  <<__Override>>
  protected async function composeAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\WritableFlow>
      $_descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
    SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow>
      $_successor_flow,
  )[defaults]: Awaitable<SGMLStreamInterfaces\Streamable> {
    await Asio\later();
    return <div class="successor">{$this->getChildren()}</div>;
  }
}
