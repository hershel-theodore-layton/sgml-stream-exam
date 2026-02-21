/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use namespace HH\Lib\C;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function query_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith3ParamsAsync(
      'getElementById',
      async () ==> vec[
        tuple(
          <doctype>
            <div>
              <div id="somethingelse"></div>
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
          expect($element->getAttribute('id'))->toEqual($id);
          expect($element->getElementById($id))->toEqual($element);
        } else {
          expect($element)->toBeNull();
        }
      },
    )
    ->testWith3ParamsAsync(
      'getElementsByClassname',
      async () ==> vec[
        tuple(
          <doctype>
            <div class="b">
              <div class="a"></div>
              <div class="b"></div>
            </div>
          </doctype>,
          'b',
          2,
        ),
      ],
      async ($element, $classname, $count)[defaults] ==> {
        $doc = await render_to_document_async($element);
        $elements = $doc->getElementsByClassname($classname);

        expect(C\count($elements))->toEqual($count);
        foreach ($elements as $e) {
          expect($e->getAttribute('class'))->toEqual($classname);
        }
      },
    )
    ->testAsync('getParent', async ()[defaults] ==> {
      $doc = await render_to_document_async(
        <doctype>
          <div id="1">
            <div id="2">
              <div id="3"></div>
              <div id="4">Some text...</div>
            </div>
          </div>
        </doctype>,
      );

      $doctype = $doc->getRootElement();
      expect($doctype->getParent($doc))->toEqual($doctype);

      foreach ($doctype->traverse() as $node) {
        foreach ($node->getChildren() as $child) {
          expect($child->getParent($doc))->toEqual($node);
        }
      }
    });
}
