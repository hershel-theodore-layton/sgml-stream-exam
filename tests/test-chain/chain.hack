/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\Project_383YMK94uxFC\GeneratedTestChain;

use namespace HTL\TestChain;

async function tests_async(
  TestChain\ChainController<\HTL\TestChain\Chain> $controller
)[defaults]: Awaitable<TestChain\ChainController<\HTL\TestChain\Chain>> {
  return $controller
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\document_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_ancestors_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_attribute_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_attributes_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_child_element_count_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_children_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_class_list_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_class_name_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_element_by_id_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_elements_by_class_name_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_first_and_last_child_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_id_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_inner_html_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_name_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_next_and_previous_sibling_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_node_id_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_node_type_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_outer_html_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_parent_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_siblings_and_self_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_text_content_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\is_element_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\piecewise_stream_tests<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\traverse_test<>);
}
