/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_node_id_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain
    ->group(__FUNCTION__)
    ->testAsync(
      'getNodeId matches traverse index and Document::getNodeByIdx()',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="a">
              <span id="b"></span>
              c
              <span id="d">
                <input id="e" />
              </span>
            </div>
          </doctype>,
        );

        $root = $doc->getRootElement();
        $nodes = vec($root->traverse());

        foreach ($nodes as $i => $node) {
          expect($node->getNodeId())->toEqual($i);
          expect($doc->getNodeByIdx($i))->toEqual($node);
        }
      },
    );
}
