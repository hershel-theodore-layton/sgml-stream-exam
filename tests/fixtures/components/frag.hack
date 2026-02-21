/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use type XHPChild;
use type HTL\SGMLStream\RootElement;
use type HTL\SGMLStreamInterfaces\{Flow, FragElement, Init, SnippetStream};

/**
 * @see sgml-stream/README.md
 */
final xhp class frag extends RootElement implements FragElement {
  const ctx INITIALIZATION_CTX = [];

  public function getFragChildren()[]: vec<XHPChild> {
    return $this->getChildren();
  }

  <<__Override>>
  public function placeIntoSnippetStream(
    SnippetStream $stream,
    Init<Flow> $init_flow,
  )[defaults]: void {
    $this->placeMyChildrenIntoSnippetStream($stream, $init_flow);
  }
}
