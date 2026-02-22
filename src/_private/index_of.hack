/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\_Private;

/**
 * Behaves like C\find($vec, $x ==> $x === $target);
 */
function index_of<<<__NonDisjoint>> T, <<__NonDisjoint>> Tel>(
  vec<T> $vec,
  Tel $target,
)[]: ?int {
  foreach ($vec as $i => $el) {
    if ($el === $target) {
      return $i;
    }
  }

  return null;
}

function index_ofx<<<__NonDisjoint>> T, <<__NonDisjoint>> Tel>(
  vec<T> $vec,
  Tel $target,
)[]: int {
  $index = index_of($vec, $target);
  invariant($index is nonnull, 'Value as not present in the vec.');
  return $index;
}
