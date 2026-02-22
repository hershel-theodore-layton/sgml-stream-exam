/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_element_by_id_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith3ParamsAsync(
      'getElementById',
      async () ==> dict[
        'can_find' => tuple(
          <doctype>
            <div>
              <div id="somethingelse"></div>
              <div id="here"></div>
            </div>
          </doctype>,
          'here',
          true,
        ),
        'cannot_find' => tuple(
          <doctype>
            <div>
              <div id="somethingelse"></div>
              <div id="here"></div>
            </div>
          </doctype>,
          'notfound',
          false,
        ),
        'two_valid_results' => tuple(
          <doctype>
            <div>
              <div id="here"></div>
              <div id="here"></div>
            </div>
          </doctype>,
          'here',
          true,
        ),
      ],
      async ($element, $id, $should_find)[defaults] ==> {
        $doc = await render_to_document_async($element);
        $element = $doc->getElementById($id);
        if ($should_find) {
          expect($element)->toBeNonnull();
          $element as nonnull;
          expect($element->getId())->toEqual($id);
          expect($element->getElementById($id))->toEqual($element);
        } else {
          expect($element)->toBeNull();
        }
      },
    );
}
