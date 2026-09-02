/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\_Private\C;

function count_if<T>(
  Traversable<T> $traversable,
  (function(T)[_]: bool) $predicate,
)[ctx $predicate]: int {
  $count = 0;
  foreach ($traversable as $value) {
    if ($predicate($value)) {
      $count++;
    }
  }
  return $count;
}
