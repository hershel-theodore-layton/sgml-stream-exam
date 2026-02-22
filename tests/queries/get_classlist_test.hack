/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use namespace HH\Lib\C;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_class_list_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'getClassList',
      async () ==> dict[
        'can_find_single_class' => tuple(
          <doctype>
            <div id="elem" class="container"></div>
          </doctype>,
          keyset['container'],
        ),
        'can_find_multiple_classes' => tuple(
          <doctype>
            <div id="elem" class="btn btn-primary btn-large"></div>
          </doctype>,
          keyset['btn', 'btn-primary', 'btn-large'],
        ),
        'returns_empty_keyset_for_element_without_class' => tuple(
          <doctype>
            <div id="elem"></div>
          </doctype>,
          keyset[],
        ),
        'returns_empty_keyset_for_element_with_empty_class' => tuple(
          <doctype>
            <div id="elem" class=""></div>
          </doctype>,
          keyset[],
        ),
        'handles_whitespace_around_classes' => tuple(
          <doctype>
            <div id="elem" class="   spaced-class   another   "></div>
          </doctype>,
          keyset['spaced-class', 'another'],
        ),
        'handles_multiple_spaces_between_classes' => tuple(
          <doctype>
            <div id="elem" class="class1    class2     class3"></div>
          </doctype>,
          keyset['class1', 'class2', 'class3'],
        ),
        'ordered_as_first_come_first_served' => tuple(
          <doctype>
            <div id="elem" class="active active disabled active"></div>
          </doctype>,
          keyset['active', 'disabled'],
        ),
        'hyphenated_and_prefixed_classes' => tuple(
          <doctype>
            <div id="elem" class="btn-primary btn-lg text-center"></div>
          </doctype>,
          keyset['btn-primary', 'btn-lg', 'text-center'],
        ),
      ],
      async ($element, $expected_classes)[defaults] ==> {
        $doc = await render_to_document_async($element);
        $elem = $doc->getElementByIdx('elem');

        $actual_classes = $elem->getClassList();
        expect($actual_classes)->toEqual($expected_classes);
      },
    );
}
