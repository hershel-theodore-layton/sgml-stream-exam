/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_text_content_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain
    ->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'getTextContent',
      async () ==> dict[
        'element_with_only_text_child_returns_that_text' => tuple(
          <doctype>
            <div id="node">Hello, world!</div>
          </doctype>,
          'Hello, world!',
        ),
        'element_with_only_whitespace_text_preserves_whitespace' => tuple(
          <doctype>
            <div id="node">{'   '}</div>
          </doctype>,
          '   ',
        ),
        'empty_element_returns_empty_string' => tuple(
          <doctype>
            <div id="node"></div>
          </doctype>,
          '',
        ),
        'element_with_nested_text_concatenates_all_text' => tuple(
          <doctype>
            <div id="node">
              <span>Hello</span>
              <span>World</span>
            </div>
          </doctype>,
          'HelloWorld',
        ),
        'deeply_nested_text_is_concatenated_in_order' => tuple(
          <doctype>
            <div id="node">
              <div>
                <span>a</span>
                <span>b</span>
              </div>
              <span>c</span>
            </div>
          </doctype>,
          'abc',
        ),
        'mixed_direct_text_and_element_children_concatenated' => tuple(
          <doctype>
            <div id="node">
              First
              <span>Middle</span>
              Last
            </div>
          </doctype>,
          ' First Middle Last ',
        ),
        'void_element_with_no_text_returns_empty_string' => tuple(
          <doctype>
            <div id="node">
              <input />
            </div>
          </doctype>,
          '',
        ),
      ],
      async ($xhp, $expected)[defaults] ==> {
        $doc = await render_to_document_async($xhp);
        $node = $doc->getElementByIdx('node');

        expect($node->getTextContent($doc))->toEqual($expected);
      },
    )
    ->testAsync(
      'getTextContent on a text node returns its own text',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="parent"> some text </div>
          </doctype>,
        );

        $parent = $doc->getElementByIdx('parent');
        $text_node = $parent->getFirstChildx();

        expect($text_node->getTextContent($doc))->toEqual(' some text ');
      },
    )
    ->testAsync(
      'getTextContent on the doctype node concatenates all text in the document',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="a">Hello</div>
            <div id="b">World</div>
          </doctype>,
        );

        $doctype = $doc->getRootElement();
        expect($doctype->getTextContent($doc))->toEqual('HelloWorld');
      },
    );
}
