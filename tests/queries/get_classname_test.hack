/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_classname_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'getClassName',
      async () ==> dict[
        'can_find_single_class' => tuple(
          <doctype>
            <div id="elem" class="container"></div>
          </doctype>,
          'container',
        ),
        'can_find_first_class_from_multiple' => tuple(
          <doctype>
            <div id="elem" class="btn btn-primary btn-large"></div>
          </doctype>,
          'btn btn-primary btn-large',
        ),
        'returns_empty_string_for_element_without_class' => tuple(
          <doctype>
            <div id="elem"></div>
          </doctype>,
          '',
        ),
        'returns_null_for_element_with_empty_class' => tuple(
          <doctype>
            <div id="elem" class=""></div>
          </doctype>,
          '',
        ),
        'handles_whitespace_in_class_attribute' => tuple(
          <doctype>
            <div id="elem" class="   spaced-class   "></div>
          </doctype>,
          '   spaced-class   ',
        ),
      ],
      async ($element, $expected_classname)[defaults] ==> {
        $doc = await render_to_document_async($element);
        $elem = $doc->getElementByIdx('elem');

        $actual_classname = $elem->getClassName();
        expect($actual_classname)->toEqual($expected_classname);
      },
    );
}
