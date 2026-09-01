/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam__\Tests;

use namespace HTL\{SGMLStream, SGMLStreamExam__, SGMLStreamInterfaces};

async function render_to_strings_async(
  SGMLStreamInterfaces\Streamable $streamable,
)[defaults]: Awaitable<vec<string>> {
  $renderer = new SGMLStream\ConcurrentReusableRenderer();
  $consumer = new SGMLStreamExam__\ToStringsConsumer();

  await $renderer->renderAsync(
    new SGMLStreamExam__\PiecewiseStream(),
    $streamable,
    $consumer,
    FlowFake::createEmpty(),
    FlowFake::createEmpty(),
    FlowFake::createEmpty(),
  );

  return $consumer->toStrings();
}
