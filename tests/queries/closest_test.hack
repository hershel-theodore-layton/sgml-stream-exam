/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStreamExam, TestChain};
use function HTL\Expect\{expect, expect_invoked};

<<TestChain\Discover>>
function closest_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'finds the nearest matching element',
      async () ==> dict[
        'self' => tuple('#leaf', 'leaf'),
        'universal' => tuple('*', 'leaf'),
        'parent' => tuple('.panel', 'inner'),
        'ancestor' => tuple('#outer', 'outer'),
        'list order' => tuple('#outer, .panel', 'inner'),
        'self before ancestor' => tuple('#outer, #leaf', 'leaf'),
        'complex selector' => tuple('#outer > div.panel', 'inner'),
        'root' => tuple(':root', 'outer'),
        'scope self' => tuple(':scope', 'leaf'),
        'scope stays on receiver' => tuple('.panel:scope', null),
        'scope inside not' => tuple('.panel:not(:scope)', 'inner'),
        'scope child' => tuple(':scope > *', null),
        'missing' => tuple('.missing', null),
        'descendant excluded' => tuple('#child', null),
        'sibling excluded' => tuple('#sibling', null),
      ],
      async ($selector, $expected_id)[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="outer" class="panel">
              <div id="inner" class="panel">
                <span id="leaf"><span id="child" /></span>
                <span id="sibling" />
              </div>
            </div>
          </doctype>,
        );
        $root = $doc->getCurrentNode();
        $leaf = $root->getElementByIdx($doc, 'leaf');
        $expected = $expected_id is null
          ? null
          : $root->getElementByIdx($doc, $expected_id);
        expect($leaf->closest($doc, $selector) === $expected)->toBeTrue();
      },
    )
    ->testWith2ParamsAsync(
      'non_elements_return_empty_results',
      async ()[defaults] ==> {
        $doc = await closest_test_edge_document_async();
        $nodes =
          $doc->getCurrentNode()->getFirstChildx($doc)->getChildren($doc);
        $nodes[] = $doc->getCurrentNode();
        $cases = dict[];
        foreach ($nodes as $node) {
          $cases[
            'node '.(string)SGMLStreamExam\node_id_to_int($node->getNodeId())
          ] = tuple($doc, $node);
        }
        return $cases;
      },
      async ($doc, $node) ==> {
        expect($node->closest($doc, '*'))->toBeNull();
      },
    )
    ->testWith3ParamsAsync(
      'invalid_selectors_are_rejected_for_every_node',
      async ()[defaults] ==> {
        $doc = await closest_test_edge_document_async();
        $nodes =
          $doc->getCurrentNode()->getFirstChildx($doc)->getChildren($doc);
        $nodes[] = $doc->getCurrentNode();
        $nodes[] = $doc->getCurrentNode()->getFirstChildx($doc);
        $cases = dict[];
        foreach ($nodes as $node) {
          foreach (vec['', '* , [', ':hover'] as $selector) {
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
        expect_invoked(() ==> $node->closest($doc, $selector))
          ->toHaveThrown<SGMLStreamExam\InvalidSelectorException>();
      },
    );
}

async function closest_test_edge_document_async(
)[defaults]: Awaitable<SGMLStreamExam\Document> {
  return await render_to_document_async(
    <doctype>
      <div>Text<conditional_comment if="IE">Comment</conditional_comment></div>
    </doctype>,
  );

}
