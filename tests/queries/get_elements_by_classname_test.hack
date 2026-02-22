/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use namespace HH\Lib\C;
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
    );
}
