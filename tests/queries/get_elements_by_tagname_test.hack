/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HH\Lib\Vec;
use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_elements_by_tag_name_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'getElementsByTagName',
      async () ==> dict[
        'matches_nested_elements_in_document_order' => tuple(
          'span',
          vec['a', 'c', 'd'],
        ),
        'uppercase_query' => tuple('SPAN', vec['a', 'c', 'd']),
        'mixed_case_query' => tuple('SpAn', vec['a', 'c', 'd']),
        'excludes_receiver_and_other_subtrees' => tuple('div', vec['b']),
        'wildcard_only_matches_elements' => tuple('*', vec['a', 'b', 'c', 'd']),
        'missing_tag' => tuple('article', vec[]),
        'empty_query' => tuple('', vec[]),
        'does_not_trim_query' => tuple(' span ', vec[]),
        'does_not_match_partial_names' => tuple('spa', vec[]),
        'does_not_match_text_nodes' => tuple('!TXTNODE', vec[]),
        'does_not_match_comments' => tuple('!COMMENT', vec[]),
      ],
      async ($tag_name, $expected_ids)[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="scope">
              Text
              <span id="a"></span>
              <div id="b"><span id="c"></span></div>
              <conditional_comment if="IE">Comment</conditional_comment>
              <span id="d"></span>
            </div>
            <div id="outside"><span id="outside-child"></span></div>
          </doctype>,
        );
        $scope = $doc->getCurrentNode()->getElementByIdx($doc, 'scope');
        $elements = $scope->getElementsByTagName($doc, $tag_name);

        expect(Vec\map($elements, $element ==> $element->getId()))
          ->toEqual($expected_ids);
      },
    )
    ->testAsync('root_and_leaf_queries', async ()[defaults] ==> {
      $doc = await render_to_document_async(
        <doctype><div id="leaf"></div></doctype>,
      );
      $root = $doc->getCurrentNode();
      $leaf = $root->getElementByIdx($doc, 'leaf');

      expect($root->getElementsByTagName($doc, '*'))->toEqual(vec[$leaf]);
      expect($root->getElementsByTagName($doc, 'div'))->toEqual(vec[$leaf]);
      expect($root->getElementsByTagName($doc, '!DOCTYPE'))->toBeEmpty();
      expect($leaf->getElementsByTagName($doc, '*'))->toBeEmpty();
      expect($leaf->getElementsByTagName($doc, 'div'))->toBeEmpty();
    });
}
