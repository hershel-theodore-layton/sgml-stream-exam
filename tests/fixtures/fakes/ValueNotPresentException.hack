/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\SGMLStreamInterfaces;

final class ValueNotPresentException
  extends \Exception
  implements SGMLStreamInterfaces\ValueNotPresentException {
  public function __construct(private string $key)[] {
    parent::__construct('Not implemented');
  }

  public function getKey()[]: string {
    return $this->key;
  }
}
