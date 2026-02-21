/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\_Private;

use namespace HTL\SGMLStreamInterfaces;

final class SGMLSnippet implements SGMLStreamInterfaces\Snippet {
  public function __construct(private string $safeSGML)[] {}

  public async function primeAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow> $_flow,
  )[defaults]: Awaitable<void> {}

  public async function feedBytesToConsumerAsync(
    SGMLStreamInterfaces\Consumer $consumer,
    SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow>
      $_successor_flow,
  )[defaults]: Awaitable<void> {
    // Unlike `HTL\SGMLStream\SGMLSnippet`, we also write empty strings
    await $consumer->consumeAsync($this->safeSGML);
  }
}
