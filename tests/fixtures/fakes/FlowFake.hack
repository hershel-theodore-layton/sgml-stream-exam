/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\SGMLStreamInterfaces;

final class FlowFake implements SGMLStreamInterfaces\CopyableFlow {
  private function __construct()[] {}

  public static function createEmpty()[]: SGMLStreamInterfaces\Chameleon<this> {
    return SGMLStreamInterfaces\cast_to_chameleon__DO_NOT_USE(new static());
  }

  public function assignVariable(
    string $_key,
    mixed $_value,
  )[write_props]: void {
    invariant_violation('Not implemented');
  }

  public function declareConstant(
    string $_key,
    mixed $_value,
  )[write_props]: void {
    invariant_violation('Not implemented');

  }

  public function get(string $_key)[]: mixed {
    return null;
  }

  public function getx(string $key)[]: mixed {
    throw new ValueNotPresentException($key);
  }

  public function has(string $_key)[]: bool {
    return false;
  }

  public function makeCopyForChild()[]: this {
    return new static();
  }
}
