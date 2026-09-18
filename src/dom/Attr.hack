/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam;

final class Attr {
  public function __construct(
    private string $name,
    private string $value,
  )[] {}

  public function getName()[]: string {
    return $this->name;
  }

  public function getValue()[]: string {
    return $this->value;
  }
}
