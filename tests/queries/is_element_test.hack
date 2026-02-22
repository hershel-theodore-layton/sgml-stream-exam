/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function is_element_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain
    ->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'isElement returns true for element nodes and false for text nodes',
      async () ==> dict[
        'an element' => tuple(
          <doctype>
            <div id="elem"></div>
          </doctype>,
          true,
        ),
        'a text node' => tuple(
          <doctype>
            Text
          </doctype>,
          false,
        ),
      ],
      async ($xhp, $is_element)[defaults] ==> {
        $doc = await render_to_document_async($xhp);
        $node = $doc->getRootElement()->getFirstChildx();

        expect($node->isElement())->toEqual($is_element);
      },
    )
    ->testAsync(
      'isElement returns false for doctype',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(<doctype></doctype>);

        $doctype = $doc->getRootElement();
        expect($doctype->isElement())->toBeFalse();
      },
    );
}
