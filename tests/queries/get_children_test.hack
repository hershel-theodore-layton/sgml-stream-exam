/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HH\Lib\Vec;
use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_children_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'getChildren',
      async () ==> dict[
        'can_find_element_children' => tuple(
          <doctype>
            <div id="parent">
              <span id="child1"></span>
              <span id="child2"></span>
              <span id="child3"></span>
            </div>
          </doctype>,
          vec[
            '<span id="child1"></span>',
            '<span id="child2"></span>',
            '<span id="child3"></span>',
          ],
        ),
        'empty_children' => tuple(
          <doctype>
            <div id="parent"></div>
          </doctype>,
          vec[],
        ),
        'single_child' => tuple(
          <doctype>
            <div id="parent"><span id="child1"></span></div>
          </doctype>,
          vec[
            '<span id="child1"></span>',
          ],
        ),
        'mixed_children' => tuple(
          <doctype>
            <div id="parent">
              Some text
              <span id="child1"></span>
              More text
              <span id="child2"></span>
            </div>
          </doctype>,
          vec[
            ' Some text ',
            '<span id="child1"></span>',
            ' More text ',
            '<span id="child2"></span>',
          ],
        ),
      ],
      async ($element, $expected)[defaults] ==> {
        $doc = await render_to_document_async($element);
        $parent = $doc->getElementByIdx('parent');

        $actual =
          Vec\map($parent->getChildren(), $c ==> $c->getOuterHTML($doc));
        expect($actual)->toEqual($expected);
      },
    );
}
