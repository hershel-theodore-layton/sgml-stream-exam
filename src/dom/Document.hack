/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam;

use namespace HH\Lib\Str;

final class Document {
  public function __construct(private Node $rootNode, private string $text)[] {}

  public function getRootElement()[]: Node {
    return $this->rootNode;
  }

  public function getText()[]: string {
    return $this->text;
  }

  public function sliceTextRange(int $start, int $end)[]: string {
    return Str\slice($this->text, $start, $end - $start);
  }
}
