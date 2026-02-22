/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStreamExam, TestChain};
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_id_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain
    ->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'getId for elements found by id',
      async () ==> dict[
        'div_id_a' => tuple(
          <doctype>
            <div id="a"></div>
          </doctype>,
          'a',
        ),
        'span_id_b' => tuple(
          <doctype>
            <span id="b"></span>
          </doctype>,
          'b',
        ),
        'nested_id' => tuple(
          <doctype>
            <div id="outer">
              <span id="inner"></span>
            </div>
          </doctype>,
          'inner',
        ),
      ],
      async ($element, $id)[defaults] ==> {
        $doc = await render_to_document_async($element);
        $node = $doc->getElementByIdx($id);

        expect($node->getId())->toEqual($id);
        expect($node->getAttribute('id'))->toEqual($id);
      },
    )
    ->testWith2ParamsAsync(
      'getId returns empty string when id attribute is missing or empty',
      async () ==> dict[
        'missing_id' => tuple(
          <doctype>
            <div id="parent">
              <span></span>
            </div>
          </doctype>,
          '',
        ),
        'empty_id' => tuple(
          <doctype>
            <div id="parent">
              <span id=""></span>
            </div>
          </doctype>,
          '',
        ),
      ],
      async ($element, $expected_id)[defaults] ==> {
        $doc = await render_to_document_async($element);
        $parent = $doc->getElementByIdx('parent');

        $child = $parent->getFirstChildx();
        expect($child->getId())->toEqual($expected_id);
      },
    )
    ->testAsync(
      'getId returns empty string for the doctype node',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="x"></div>
          </doctype>,
        );

        $doctype = $doc->getRootElement();
        expect($doctype->getName())->toEqual(SGMLStreamExam\Node::DOCTYPE_NAME);
        expect($doctype->getId())->toEqual('');
      },
    )
    ->testAsync(
      'getId returns empty string for text nodes',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="parent">
              Some text
            </div>
          </doctype>,
        );

        $parent = $doc->getElementByIdx('parent');
        $text = $parent->getFirstChildx();

        expect($text->getName())->toEqual(SGMLStreamExam\Node::TXTNODE_NAME);
        expect($text->getId())->toEqual('');
      },
    );
}
