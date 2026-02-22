/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\Project_383YMK94uxFC\GeneratedTestChain;

use namespace HTL\TestChain;

async function tests_async(
  TestChain\ChainController<\HTL\TestChain\Chain> $controller
)[defaults]: Awaitable<TestChain\ChainController<\HTL\TestChain\Chain>> {
  return $controller
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\document_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_element_by_id_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_elements_by_classname_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_parent_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\piecewise_stream_tests<>);
}
