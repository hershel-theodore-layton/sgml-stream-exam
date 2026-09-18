/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStreamExam, TestChain};
use type HH\InvariantException;
use function HTL\Expect\{expect, expect_invoked};

<<TestChain\Discover>>
function query_selector_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'querySelector',
      async () ==> dict[
        'first_match_in_tree_order' => tuple('.item', 'nested'),
        'selector_list_order' => tuple('#last, #nested', 'nested'),
        'wildcard_skips_text_and_comments' => tuple('*', 'wrapper'),
        'excludes_receiver' => tuple('#scope', null),
        'excludes_other_subtrees' => tuple('#outside', null),
        'no_match' => tuple('.missing', null),
        'scope_itself_is_not_returned' => tuple(':scope', null),
        'scoped_direct_child' => tuple(':scope > .item', 'last'),
        'scope_inside_logical_selector' => tuple(':is(:scope) > .item', 'last'),
        'scope_descendant' => tuple(':scope .item', 'nested'),
        'ancestor_outside_subtree' => tuple('#outer .item', 'nested'),
        'sibling_combinator' => tuple('#wrapper + span', 'last'),
        'attribute_selector' => tuple('[data-value="yes"]', 'last'),
        'forgiving_selector_list' => tuple(':is(:unknown, .item)', 'nested'),
      ],
      async ($selector, $expected_id)[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="outer">
              <span id="outside" class="item"></span>
              <div id="scope" class="item">
                Text
                <conditional_comment if="IE">Comment</conditional_comment>
                <div id="wrapper"><span id="nested" class="item"></span></div>
                <span id="last" class="item" data-value="yes"></span>
              </div>
            </div>
          </doctype>,
        );
        $scope = $doc->getCurrentNode()->getElementByIdx($doc, 'scope');
        expect($scope->querySelector($doc, $selector)?->getId())
          ->toEqual($expected_id);
      },
    )
    ->testAsync('root_leaf_and_non_element_queries', async ()[defaults] ==> {
      $doc = await render_to_document_async(
        <doctype>
          Text
          <conditional_comment if="IE">Comment</conditional_comment>
          <span id="leaf"></span>
        </doctype>,
      );
      $root = $doc->getCurrentNode();
      $leaf = $root->getElementByIdx($doc, 'leaf');
      expect($root->querySelector($doc, '*'))->toEqual($leaf);

      foreach ($root->getChildren($doc) as $node) {
        expect($node->querySelector($doc, '*'))->toBeNull();
      }
      foreach ($root->getDescendantsAndSelf($doc) as $node) {
        foreach (vec['', 'span, [', '*,:unknown'] as $selector) {
          expect_invoked(() ==> $node->querySelector($doc, $selector))
            ->toHaveThrown<SGMLStreamExam\InvalidSelectorException>();
        }
      }

      $other_doc = new SGMLStreamExam\Document();
      expect_invoked(() ==> $root->querySelector($other_doc, '*'))
        ->toHaveThrown<InvariantException>('The document must own this node.');
    });
}
