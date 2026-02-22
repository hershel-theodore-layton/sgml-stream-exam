/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_parent_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testAsync('getParent', async ()[defaults] ==> {
      $doc = await render_to_document_async(
        <doctype>
          <div id="1">
            <div id="2">
              <div id="3"></div>
              <div id="4">Some text...</div>
            </div>
          </div>
        </doctype>,
      );

      $doctype = $doc->getRootElement();
      expect($doctype->getParent($doc))->toEqual($doctype);

      foreach ($doctype->traverse() as $node) {
        foreach ($node->getChildren() as $child) {
          expect($child->getParent($doc))->toEqual($node);
        }
      }
    });
}
