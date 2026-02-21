/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use type HTL\SGMLStream\RootElement;
use type HTL\SGMLStreamInterfaces\{Flow, Init, SnippetStream};

/**
 * @see sgml-stream/README.md
 */
final xhp class doctype extends RootElement {
  const ctx INITIALIZATION_CTX = [];

  <<__Override>>
  public function placeIntoSnippetStream(
    SnippetStream $stream,
    Init<Flow> $init_flow,
  )[defaults]: void {
    $stream->addSafeSGML('<!DOCTYPE html>');
    $this->placeMyChildrenIntoSnippetStream($stream, $init_flow);
  }
}
