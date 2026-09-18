/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\_Private;

// tuple(?string, string), but closely packed.
// Tuples allocate more memory than required.
final class AttributeValue {
  public function __construct(
    private ?string $originalName,
    private string $value,
  )[] {}

  public function getName(string $normalized_name)[]: string {
    return $this->originalName ?? $normalized_name;
  }

  public function getValue()[]: string {
    return $this->value;
  }
}
