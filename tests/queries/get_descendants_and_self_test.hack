/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HH\Lib\C;
use namespace HTL\{SGMLStreamExam, TestChain};
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_descendants_and_self_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testAsync(
      'getDescendantsAndSelf yields nodes in pre-order, including text nodes',
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

        $root = $doc->getCurrentNode();
        $nodes = $root->getDescendantsAndSelf($doc);

        expect(C\count($nodes))->toEqual(6);

        expect($nodes[0]->getName())
          ->toEqual(SGMLStreamExam\Node::DOCTYPE);
        expect($nodes[1]->getId())->toEqual('a');
        expect($nodes[2]->getId())->toEqual('b');
        expect($nodes[3]->getName())
          ->toEqual(SGMLStreamExam\Node::TXTNODE);
        expect($nodes[3]->getOuterHTML($doc))->toEqual(' c ');
        expect($nodes[4]->getId())->toEqual('d');
        expect($nodes[5]->getId())->toEqual('e');
      },
    );
}
