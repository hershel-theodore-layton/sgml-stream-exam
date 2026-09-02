/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\Project_383YMK94uxFC\GeneratedTestChain;

use namespace HTL\TestChain;

async function tests_async(
  TestChain\ChainController<\HTL\TestChain\Chain> $controller,
)[defaults]: Awaitable<TestChain\ChainController<\HTL\TestChain\Chain>> {
  return $controller
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\document_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_element_by_id_test<>);
}
