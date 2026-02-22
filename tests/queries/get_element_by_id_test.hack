/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HH\Lib\Str;
use namespace HTL\TestChain;
use function HTL\Expect\{expect, expect_invoked};

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
          $element = expect($element)->toBeNonnull()->getValue();
          expect($doc->getElementByIdx($id))->toEqual($element);
          expect($element->getId())->toEqual($id);
          expect($element->getElementById($id))->toBeNull();
        } else {
          expect($element)->toBeNull();
          expect_invoked(() ==> $doc->getElementByIdx($id))
            ->toHaveThrown<InvariantException>(
              Str\format('Element with the id "%s" was not found.', $id),
            );
        }
      },
    )
    ->testAsync(
      'getElementById searches within the receiver subtree (and does not match the receiver node itself)',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="left">
              <span id="left_child"></span>
            </div>
            <div id="right">
              <span id="right_child"></span>
            </div>
          </doctype>,
        );

        $left = $doc->getElementByIdx('left');
        $right = $doc->getElementByIdx('right');

        $left_child = $left->getElementById('left_child');
        $left_child = expect($left_child)->toBeNonnull()->getValue();
        expect($left_child->getId())->toEqual('left_child');

        $right_child = $right->getElementById('right_child');
        $right_child = expect($right_child)->toBeNonnull()->getValue();
        expect($right_child->getId())->toEqual('right_child');

        expect($left->getElementById('right_child'))->toBeNull();
        expect($right->getElementById('left_child'))->toBeNull();

        expect($left->getElementById('left'))->toBeNull();
        expect($right->getElementById('right'))->toBeNull();
      },
    )
    ->testAsync(
      'getElementById returns the first match when duplicate ids exist in the receiver subtree',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="scope">
              <span id="dup">First</span>
              <span id="dup">Second</span>
            </div>
          </doctype>,
        );

        $dup = $doc->getElementByIdx('dup');
        expect($dup->getOuterHTML($doc))->toEqual('<span id="dup">First</span>');
      },
    );
}
