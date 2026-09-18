/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\Project_383YMK94uxFC\GeneratedTestChain;

use namespace HTL\TestChain;
use type HTL\Pragma\Pragmas;

<<file: Pragmas(vec['PhaLinters', 'digest:64bfe758a7e4ebfc0664'])>>

async function tests_async(
  TestChain\ChainController<\HTL\TestChain\Chain> $controller,
)[defaults]: Awaitable<TestChain\ChainController<\HTL\TestChain\Chain>> {
  return $controller
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\contains_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\document_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_ancestors_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_attribute_names_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_attribute_node_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_attribute_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_attributes_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_child_element_count_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_children_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_class_list_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_class_name_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_dataset_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_descendants_and_self_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_element_by_id_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_elements_by_class_name_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_elements_by_tag_name_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_first_and_last_child_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_first_and_last_element_child_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_id_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_inner_html_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_name_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_next_and_previous_element_sibling_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_next_and_previous_sibling_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_node_id_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_node_type_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_node_value_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_outer_html_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_parent_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_siblings_and_self_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\get_text_content_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\has_attribute_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\has_attributes_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\has_child_nodes_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\is_element_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\is_equal_node_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\matches_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\query_selector_all_test<>)
    ->addTestGroup(\HTL\SGMLStreamExam\Tests\query_selector_test<>);
}
