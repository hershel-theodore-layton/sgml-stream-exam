/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use namespace HH\Lib\C;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_elements_by_classname_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith3ParamsAsync(
      'getElementsByClassname',
      async () ==> dict[
        'can_find' => tuple(
          <doctype>
            <div class="b">
              <div class="a"></div>
              <div class="b"></div>
            </div>
          </doctype>,
          'b',
          2,
        ),
        'cannot_find' => tuple(
          <doctype>
            <div class="b">
              <div class="a"></div>
              <div class="b"></div>
            </div>
          </doctype>,
          'c',
          0,
        ),
      ],
      async ($element, $classname, $count)[defaults] ==> {
        $doc = await render_to_document_async($element);
        $elements = $doc->getElementsByClassname($classname);

        expect(C\count($elements))->toEqual($count);
        foreach ($elements as $e) {
          expect($e->getClassName())->toEqual($classname);
          expect($e->getElementsByClassname($classname))->toContainElement($e);
        }
      },
    );
}
