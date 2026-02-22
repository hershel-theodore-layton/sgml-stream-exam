/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_inner_html_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain
    ->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'getInnerHTML',
      async () ==> dict[
        'empty_element_has_empty_inner_html' =>
          tuple(<doctype><div id="parent"></div></doctype>, ''),
        'element_children_only_concatenates_child_outer_html' => tuple(
          <doctype>
            <div id="parent"><span id="a"></span><span id="b"></span></div>
          </doctype>,
          '<span id="a"></span><span id="b"></span>',
        ),
        'mixed_text_and_elements_preserves_text_whitespace' => tuple(
          <doctype>
            <div id="parent">
              Some text
              <span id="elem"></span>
              More text
            </div>
          </doctype>,
          ' Some text <span id="elem"></span> More text ',
        ),
        'includes_void_elements_without_self_closing_slash' => tuple(
          <doctype>
            <div id="parent">
              <input id="x" />
              <span id="y"></span>
            </div>
          </doctype>,
          '<input id="x"><span id="y"></span>',
        ),
      ],
      async ($xhp, $expected_inner_html)[defaults] ==> {
        $doc = await render_to_document_async($xhp);

        $node = $doc->getElementByIdx('parent');
        expect($node->getInnerHTML($doc))->toEqual($expected_inner_html);
      },
    );
}
