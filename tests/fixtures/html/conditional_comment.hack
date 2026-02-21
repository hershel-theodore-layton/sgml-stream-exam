/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use type HTL\SGMLStream\RootElement;
use type HTL\SGMLStreamInterfaces\{Flow, Init, SnippetStream};

/**
 * @see sgml-stream/README.md
 */
final xhp class conditional_comment extends RootElement {
  const ctx INITIALIZATION_CTX = [];
  attribute string if @required;

  <<__Override>>
  public function placeIntoSnippetStream(
    SnippetStream $stream,
    Init<Flow> $init_flow,
  )[defaults]: void {
    // This is unsafe, since the string passed for `->:if` could break out
    // of this comment and ruin your document. Be careful!
    $stream->addSafeSGML('<!--[if '.$this->:if.']>');
    $this->placeMyChildrenIntoSnippetStream($stream, $init_flow);
    $stream->addSafeSGML('<![endif]-->');
  }
}
