/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HH\Lib\Vec;
use namespace HTL\{SGMLStreamExam, TestChain};
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_siblings_and_self_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain
    ->group(__FUNCTION__)
    ->testAsync(
      'getSiblingsAndSelf returns all siblings (including self) in parent child order for element-only children',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="parent">
              <span id="a"></span>
              <span id="b"></span>
              <span id="c"></span>
            </div>
          </doctype>,
        );

        $b = $doc->getElementByIdx('b');
        $siblings_and_self = $b->getSiblingsAndSelf($doc);

        expect(Vec\map($siblings_and_self, $n ==> $n->getId()))
          ->toEqual(vec['a', 'b', 'c']);
      },
    )
    ->testAsync(
      'getSiblingsAndSelf includes text node siblings',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="parent">
              First
              <span id="a"></span>
              Middle
              <span id="b"></span>
              Last
            </div>
          </doctype>,
        );

        $parent = $doc->getElementByIdx('parent');
        $children = $parent->getChildren();

        expect(Vec\map($children, $c ==> $c->getOuterHTML($doc)))->toEqual(vec[
          ' First ',
          '<span id="a"></span>',
          ' Middle ',
          '<span id="b"></span>',
          ' Last ',
        ]);
      },
    )
    ->testAsync(
      'getSiblingsAndSelf returns only self when parent has a single child',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="parent">
              <span id="only"></span>
            </div>
          </doctype>,
        );

        $only = $doc->getElementByIdx('only');
        $siblings_and_self = $only->getSiblingsAndSelf($doc);

        expect(Vec\map($siblings_and_self, $n ==> $n->getId()))
          ->toEqual(vec['only']);
      },
    )
    ->testAsync(
      'getSiblingsAndSelf on the doctype node returns only itself',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="x"></div>
          </doctype>,
        );

        $doctype = $doc->getRootElement();
        expect($doctype->getName())->toEqual(SGMLStreamExam\Node::DOCTYPE_NAME);

        $siblings_and_self = $doctype->getSiblingsAndSelf($doc);
        expect(Vec\map($siblings_and_self, $n ==> $n->getName()))
          ->toEqual(vec[SGMLStreamExam\Node::DOCTYPE_NAME]);
      },
    );
}
