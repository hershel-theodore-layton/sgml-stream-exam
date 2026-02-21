/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStream, SGMLStreamExam, SGMLStreamInterfaces};

async function render_to_strings_async(
  SGMLStreamInterfaces\Streamable $streamable,
)[defaults]: Awaitable<vec<string>> {
  $renderer = new SGMLStream\ConcurrentReusableRenderer();
  $consumer = new SGMLStreamExam\ToStringsConsumer();

  await $renderer->renderAsync(
    new SGMLStreamExam\PiecewiseStream(),
    $streamable,
    $consumer,
    FlowFake::createEmpty(),
    FlowFake::createEmpty(),
    FlowFake::createEmpty(),
  );

  return $consumer->toStrings();
}
