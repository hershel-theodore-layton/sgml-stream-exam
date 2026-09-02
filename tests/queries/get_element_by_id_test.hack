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
        $root = $doc->getCurrentNode();
        $element = $root->getElementById($doc, $id);

        if ($should_find) {
          $element = expect($element)->toBeNonnull()->getValue();
          expect($root->getElementByIdx($doc, $id))->toEqual($element);
          expect($element->getId())->toEqual($id);
          expect($element->getElementById($doc, $id))->toBeNull();
        } else {
          expect($element)->toBeNull();
          expect_invoked(() ==> $root->getElementByIdx($doc, $id))
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

        $root = $doc->getCurrentNode();

        $left = $root->getElementByIdx($doc, 'left');
        $right = $root->getElementByIdx($doc, 'right');

        $left_child = $left->getElementById($doc, 'left_child');
        $left_child = expect($left_child)->toBeNonnull()->getValue();
        expect($left_child->getId())->toEqual('left_child');

        $right_child = $right->getElementById($doc, 'right_child');
        $right_child = expect($right_child)->toBeNonnull()->getValue();
        expect($right_child->getId())->toEqual('right_child');

        expect($left->getElementById($doc, 'right_child'))->toBeNull();
        expect($right->getElementById($doc, 'left_child'))->toBeNull();

        expect($left->getElementById($doc, 'left'))->toBeNull();
        expect($right->getElementById($doc, 'right'))->toBeNull();
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

        $root = $doc->getCurrentNode();

        $dup = $root->getElementByIdx($doc, 'dup');
        expect($dup->getOuterHTML($doc))->toEqual(
          '<span id="dup">First</span>',
        );
      },
    );
}
