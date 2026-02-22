/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use namespace HH\Lib\{C, Vec};
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_elements_by_class_name_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith3ParamsAsync(
      'getElementsByClassName',
      async () ==> dict[
        'can_find_single_class_direct_match' => tuple(
          <doctype>
            <div class="a"></div>
            <div class="b"></div>
          </doctype>,
          'a',
          1,
        ),
        'can_find_multiple_class_elements' => tuple(
          <doctype>
            <div class="b">
              <div class="a"></div>
              <div class="b"></div>
            </div>
          </doctype>,
          'b',
          2,
        ),
        'cannot_find_nonexistent_class' => tuple(
          <doctype>
            <div class="b">
              <div class="a"></div>
              <div class="b"></div>
            </div>
          </doctype>,
          'c',
          0,
        ),
        'find_element_by_inner_class' => tuple(
          <doctype>
            <div class="foo bar baz"></div>
            <div class="foo"></div>
          </doctype>,
          'bar',
          1,
        ),
        'find_multiple_elements_with_same_inner_class' => tuple(
          <doctype>
            <div class="foo bar"></div>
            <div class="bar baz"></div>
            <div class="baz"></div>
          </doctype>,
          'bar',
          2,
        ),
        'find_all_elements_with_shared_class' => tuple(
          <doctype>
            <div class="alpha beta gamma"></div>
            <div class="beta"></div>
            <div class="gamma beta"></div>
            <div class="delta"></div>
          </doctype>,
          'beta',
          3,
        ),
        'class_name_with_whitespace_around' => tuple(
          <doctype>
            <div class="   odd   even  "></div>
            <div class="odd"></div>
          </doctype>,
          'even',
          1,
        ),
      ],
      async ($element, $class_name, $count)[defaults] ==> {
        $doc = await render_to_document_async($element);
        $elements = $doc->getElementsByClassName($class_name);

        expect(C\count($elements))->toEqual($count);
        foreach ($elements as $e) {
          expect($e->getClassList())->toContainElement($class_name);
        }
      },
    )
    ->testAsync(
      'getElementsByClassName searches within the receiver subtree (does not include nodes outside)',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="left">
              <span id="left_a" class="target"></span>
              <div id="left_b">
                <span id="left_c" class="target"></span>
              </div>
            </div>
            <div id="right">
              <span id="right_a" class="target"></span>
            </div>
          </doctype>,
        );

        $left = $doc->getElementByIdx('left');
        $right = $doc->getElementByIdx('right');

        $left_hits = $left->getElementsByClassName('target');
        $right_hits = $right->getElementsByClassName('target');

        expect(Vec\map($left_hits, $n ==> $n->getId()))
          ->toEqual(vec['left_a', 'left_c']);

        expect(C\count($right_hits))->toEqual(1);
        expect(Vec\map($right_hits, $n ==> $n->getId()))
          ->toEqual(vec['right_a']);
      },
    )
    ->testAsync(
      'getElementsByClassName returns matches in document (pre-order traversal) order within the receiver subtree',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="scope">
              <span id="a" class="x"></span>
              <div id="b" class="x">
                <span id="c" class="x"></span>
              </div>
              <span id="d" class="x"></span>
            </div>
          </doctype>,
        );

        $scope = $doc->getElementByIdx('scope');
        $hits = $scope->getElementsByClassName('x');

        expect(Vec\map($hits, $n ==> $n->getId()))
          ->toEqual(vec['a', 'b', 'c', 'd']);
      },
    )
    ->testAsync(
      'getElementsByClassName returns an empty vec when there are no matches in the receiver subtree',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="scope">
              <span id="a" class="not-it"></span>
              <div id="b">
                <span id="c"></span>
              </div>
            </div>
          </doctype>,
        );

        $scope = $doc->getElementByIdx('scope');
        $hits = $scope->getElementsByClassName('missing');

        expect($hits)->toBeEmpty();
      },
    )
    ->testAsync(
      'getElementsByClassName matches when the class is one among multiple classes (including extra whitespace)',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="scope">
              <span id="a" class="foo   target  bar"></span>
              <span id="b" class="target"></span>
              <span id="c" class="foo bar"></span>
              <div id="d" class="  target   ">
                <span id="e" class="target baz"></span>
              </div>
            </div>
          </doctype>,
        );

        $scope = $doc->getElementByIdx('scope');
        $hits = $scope->getElementsByClassName('target');

        expect(Vec\map($hits, $n ==> $n->getId()))
          ->toEqual(vec['a', 'b', 'd', 'e']);

        foreach ($hits as $hit) {
          expect($hit->getClassList())->toContainElement('target');
        }
      },
    );
}
