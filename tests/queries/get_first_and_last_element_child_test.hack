/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_first_and_last_element_child_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith3ParamsAsync(
      'getFirstElementChild / getLastElementChild',
      async () ==> dict[
        'no_children' => tuple(
          <doctype><div></div></doctype>,
          null,
          null,
        ),
        'only_text' => tuple(
          <doctype><div>Only text</div></doctype>,
          null,
          null,
        ),
        'only_comments' => tuple(
          <doctype>
            <div>
              <conditional_comment if="IE">Comment</conditional_comment>
            </div>
          </doctype>,
          null,
          null,
        ),
        'single_element' => tuple(
          <doctype><div><span id="only"></span></div></doctype>,
          'only',
          'only',
        ),
        'multiple_elements' => tuple(
          <doctype>
            <div>
              <span id="first"></span>
              <span id="middle"></span>
              <span id="last"></span>
            </div>
          </doctype>,
          'first',
          'last',
        ),
        'skips_text_and_comments' => tuple(
          <doctype>
            <div>
              Leading text
              <conditional_comment if="IE">Before</conditional_comment>
              <span id="first"></span>
              Middle text
              <span id="last"></span>
              <conditional_comment if="IE">After</conditional_comment>
              Trailing text
            </div>
          </doctype>,
          'first',
          'last',
        ),
        'returns_direct_children' => tuple(
          <doctype>
            <div>
              <span id="first"><span id="nested-first"></span></span>
              <span id="last"><span id="nested-last"></span></span>
            </div>
          </doctype>,
          'first',
          'last',
        ),
      ],
      async ($element, $expected_first, $expected_last)[defaults] ==> {
        $doc = await render_to_document_async($element);
        $parent = $doc->getCurrentNode()->getFirstChildx($doc);

        expect($parent->getFirstElementChild($doc)?->getId())
          ->toEqual($expected_first);
        expect($parent->getLastElementChild($doc)?->getId())
          ->toEqual($expected_last);
      },
    );
}
