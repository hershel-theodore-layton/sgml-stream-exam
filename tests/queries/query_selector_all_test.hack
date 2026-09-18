/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HH\Lib\{C, Vec};
use namespace HTL\{SGMLStreamExam, TestChain};
use function HTL\Expect\{expect, expect_invoked};

<<TestChain\Discover>>
function query_selector_all_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'querySelectorAll',
      async () ==> dict[
        'document_order' => tuple('.item', vec['nested', 'last']),
        'selector_list_order' => tuple('#last, #nested', vec['nested', 'last']),
        'no_duplicates' => tuple('.item, span, #last', vec['nested', 'last']),
        'wildcard' => tuple('*', vec['wrapper', 'nested', 'last']),
        'excludes_receiver' => tuple('#scope', vec[]),
        'excludes_other_subtrees' => tuple('#outside', vec[]),
        'no_match' => tuple('.missing', vec[]),
        'scope_is_not_returned' => tuple(':scope', vec[]),
        'scoped_direct_children' => tuple(':scope > *', vec['wrapper', 'last']),
        'nested_scope' => tuple(':is(:scope) .item', vec['nested', 'last']),
        'ancestor_outside_subtree' => tuple(
          '#outer #scope .item',
          vec['nested', 'last'],
        ),
        'sibling_combinator' => tuple('#wrapper + span', vec['last']),
        'forgiving_list' => tuple(':is(:unknown, .item)', vec['nested', 'last']),
      ],
      async ($selector, $expected_ids)[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="outer">
              <span id="outside" class="item"></span>
              <div id="scope" class="item">
                Text
                <conditional_comment if="IE">Comment</conditional_comment>
                <div id="wrapper"><span id="nested" class="item"></span></div>
                <span id="last" class="item"></span>
              </div>
            </div>
          </doctype>,
        );
        $scope = $doc->getCurrentNode()->getElementByIdx($doc, 'scope');
        $matches = $scope->querySelectorAll($doc, $selector);
        expect(Vec\map($matches, $node ==> $node->getId()))
          ->toEqual($expected_ids);
        expect(C\first($matches))
          ->toEqual($scope->querySelector($doc, $selector));
      },
    )
    ->testAsync('root_leaf_and_non_element_queries', async ()[defaults] ==> {
      $doc = await render_to_document_async(
        <doctype>
          Text
          <conditional_comment if="IE">Comment</conditional_comment>
          <span id="first"></span>
          <span id="last"></span>
        </doctype>,
      );
      $root = $doc->getCurrentNode();
      expect($root->querySelectorAll($doc, '*'))->toEqual(vec[
        $root->getElementByIdx($doc, 'first'),
        $root->getElementByIdx($doc, 'last'),
      ]);
      foreach ($root->getChildren($doc) as $node) {
        expect($node->querySelectorAll($doc, '*'))->toEqual(vec[]);
      }
      foreach ($root->getDescendantsAndSelf($doc) as $node) {
        foreach (vec['', 'span, [', '*,:unknown'] as $selector) {
          expect_invoked(() ==> $node->querySelectorAll($doc, $selector))
            ->toHaveThrown<SGMLStreamExam\InvalidSelectorException>();
        }
      }
    });
}
