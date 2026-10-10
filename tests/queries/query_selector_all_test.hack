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
        'ancestor_outside_subtree' =>
          tuple('#outer #scope .item', vec['nested', 'last']),
        'sibling_combinator' => tuple('#wrapper + span', vec['last']),
        'forgiving_list' =>
          tuple(':is(:unknown, .item)', vec['nested', 'last']),
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
    ->testAsync('root_queries', async ()[defaults] ==> {
      $doc = await query_selector_all_test_edge_document_async();
      $root = $doc->getCurrentNode();
      expect($root->querySelectorAll($doc, '*'))->toEqual(vec[
        $root->getElementByIdx($doc, 'first'),
        $root->getElementByIdx($doc, 'last'),
      ]);
    })
    ->testWith2ParamsAsync(
      'non_elements_and_leaves_return_empty_results',
      async ()[defaults] ==> {
        $doc = await query_selector_all_test_edge_document_async();
        $nodes = $doc->getCurrentNode()->getChildren($doc);
        $cases = dict[];
        foreach ($nodes as $node) {
          $cases[
            'node '.(string)SGMLStreamExam\node_id_to_int($node->getNodeId())
          ] = tuple($doc, $node);
        }
        return $cases;
      },
      async ($doc, $node) ==> {
        expect($node->querySelectorAll($doc, '*'))->toEqual(vec[]);
      },
    )
    ->testWith3ParamsAsync(
      'invalid_selectors_are_rejected_for_every_node',
      async ()[defaults] ==> {
        $doc = await query_selector_all_test_edge_document_async();
        $nodes = $doc->getCurrentNode()->getDescendantsAndSelf($doc);
        $cases = dict[];
        foreach ($nodes as $node) {
          foreach (vec['', 'span, [', '*,:unknown'] as $selector) {
            $cases[
              (string)SGMLStreamExam\node_id_to_int($node->getNodeId()).
              ' '.
              $selector
            ] = tuple($doc, $node, $selector);
          }
        }
        return $cases;
      },
      async ($doc, $node, string $selector) ==> {
        expect_invoked(() ==> $node->querySelectorAll($doc, $selector))
          ->toHaveThrown<SGMLStreamExam\InvalidSelectorException>();
      },
    );
}

async function query_selector_all_test_edge_document_async(
)[defaults]: Awaitable<SGMLStreamExam\Document> {
  return await render_to_document_async(
    <doctype>
      Text
      <conditional_comment if="IE">Comment</conditional_comment>
      <span id="first"></span>
      <span id="last"></span>
    </doctype>,
  );

}
