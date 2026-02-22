/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_child_element_count_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  return $chain
    ->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'getChildElementCount',
      async () ==> dict[
        'no_children' => tuple(
          <doctype>
            <div id="parent"></div>
          </doctype>,
          0,
        ),
        'only_element_children' => tuple(
          <doctype>
            <div id="parent">
              <span id="a"></span>
              <span id="b"></span>
              <input id="c" />
            </div>
          </doctype>,
          3,
        ),
        'mixed_text_and_elements_counts_only_elements' => tuple(
          <doctype>
            <div id="parent">
              Some text
              <span id="a"></span>
              More text
              <span id="b"></span>
            </div>
          </doctype>,
          2,
        ),
        'only_text_children_counts_as_zero' => tuple(
          <doctype>
            <div id="parent">
              Only text
            </div>
          </doctype>,
          0,
        ),
      ],
      async ($xhp, $expected)[defaults] ==> {
        $doc = await render_to_document_async($xhp);
        $parent = $doc->getElementByIdx('parent');

        expect($parent->getChildElementCount())->toEqual($expected);
      },
    );
}
