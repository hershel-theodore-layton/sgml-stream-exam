/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam;

use namespace HTL\SGMLStreamInterfaces;

final class PiecewiseStream implements SGMLStreamInterfaces\SnippetStream {
  private vec<SGMLStreamInterfaces\Snippet> $snippets = vec[];

  public function addSafeSGML(string $safe_sgml)[write_props]: void {
    $this->snippets[] = new _Private\SGMLSnippet($safe_sgml);
  }

  public function addSnippet(
    SGMLStreamInterfaces\Snippet $snippet,
  )[write_props]: void {
    $this->snippets[] = $snippet;
  }

  public function collect()[write_props]: vec<SGMLStreamInterfaces\Snippet> {
    return $this->snippets;
  }

  public function streamOf(
    SGMLStreamInterfaces\Streamable $streamable,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $init_flow,
  )[defaults]: this {
    $me = new static();
    $streamable->placeIntoSnippetStream($me, $init_flow);
    return $me;
  }
}
