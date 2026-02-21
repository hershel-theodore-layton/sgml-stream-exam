/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\_Private;

use namespace HH\Lib\C;

final class Stack<T> {
  private int $stackPtr;

  public function __construct(private vec<T> $stack = vec[])[] {
    $this->stackPtr = C\count($stack) - 1;
  }

  public function push(T $value)[write_props]: void {
    $this->stackPtr++;
    if (C\count($this->stack) === $this->stackPtr) {
      $this->stack[] = $value;
    } else {
      $this->stack[$this->stackPtr] = $value;
    }
  }

  public function pop()[write_props]: T {
    $element = $this->stack[$this->stackPtr];
    $this->stack[$this->stackPtr] = $this->stack[0];
    $this->stackPtr--;
    return $element;
  }

  public function peek()[]: T {
    return $this->stack[$this->stackPtr];
  }
}
