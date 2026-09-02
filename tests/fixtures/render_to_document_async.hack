/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStream, SGMLStreamExam, SGMLStreamInterfaces};

async function render_to_document_async(
  SGMLStreamInterfaces\Streamable $streamable,
)[defaults]: Awaitable<SGMLStreamExam\Document> {
  $renderer = new SGMLStream\ConcurrentReusableRenderer();
  $consumer = new SGMLStreamExam\ToHTMLDocumentConsumer();

  await $renderer->renderAsync(
    new SGMLStreamExam\PiecewiseStream(),
    $streamable,
    $consumer,
    FlowFake::createEmpty(),
    FlowFake::createEmpty(),
    FlowFake::createEmpty(),
  );

  return $consumer->toDocument();
}
