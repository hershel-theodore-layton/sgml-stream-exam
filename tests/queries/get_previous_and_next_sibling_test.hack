/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_next_and_previous_sibling_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  return $chain
    ->group(__FUNCTION__)
    ->testWith4ParamsAsync(
      'getNextSibling / getPreviousSibling',
      async () ==> dict[
        'mixed_children_a_prev_and_next_are_text_nodes' => tuple(
          <doctype>
            <div id="parent">
              First
              <span id="a"></span>
              Middle
              <span id="b"></span>
              Last
            </div>
          </doctype>,
          'a',
          ' First ',
          ' Middle ',
        ),
        'element_only_middle_has_neighbors' => tuple(
          <doctype>
            <div id="parent">
              <span id="a"></span>
              <span id="b"></span>
              <span id="c"></span>
            </div>
          </doctype>,
          'b',
          '<span id="a"></span>',
          '<span id="c"></span>',
        ),
        'element_only_first_prev_null_next_b' => tuple(
          <doctype>
            <div id="parent">
              <span id="a"></span>
              <span id="b"></span>
              <span id="c"></span>
            </div>
          </doctype>,
          'a',
          null,
          '<span id="b"></span>',
        ),
        'element_only_last_prev_b_next_null' => tuple(
          <doctype>
            <div id="parent">
              <span id="a"></span>
              <span id="b"></span>
              <span id="c"></span>
            </div>
          </doctype>,
          'c',
          '<span id="b"></span>',
          null,
        ),
        'single_child_has_no_siblings' => tuple(
          <doctype>
            <div id="parent">
              <span id="only"></span>
            </div>
          </doctype>,
          'only',
          null,
          null,
        ),
      ],
      async (
        $xhp,
        $subject_id,
        $expected_previous,
        $expected_next,
      )[defaults] ==> {
        $doc = await render_to_document_async($xhp);
        $subject = $doc->getElementByIdx($subject_id);

        $prev = $subject->getPreviousSibling($doc)?->getOuterHTML($doc);
        $next = $subject->getNextSibling($doc)?->getOuterHTML($doc);

        expect($prev)->toEqual($expected_previous);
        expect($next)->toEqual($expected_next);
      },
    );
}
