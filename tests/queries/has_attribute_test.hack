/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function has_attribute_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'hasAttribute',
      async () ==> dict[
        'html_attribute_names_are_ascii_case_insensitive' => tuple(
          <doctype><div data-value="hello"></div></doctype>,
          dict['data-value' => true, 'DATA-VALUE' => true, 'DaTa-VaLuE' => true],
        ),
        'present_and_missing_attributes' => tuple(
          <doctype>
            <div id="elem" class="container" data-value="hello"></div>
          </doctype>,
          dict[
            'id' => true,
            'class' => true,
            'data-value' => true,
            'missing-attr' => false,
          ],
        ),
        'no_attributes' => tuple(
          <doctype><div></div></doctype>,
          dict['id' => false, '' => false],
        ),
        'empty_and_zero_values_are_present' => tuple(
          <doctype><div class="" data-empty="" data-zero="0"></div></doctype>,
          dict['class' => true, 'data-empty' => true, 'data-zero' => true],
        ),
        'boolean_attribute' => tuple(
          <doctype><input autofocus={SET} /></doctype>,
          dict['autofocus' => true, 'hidden' => false],
        ),
        'only_checks_own_attributes' => tuple(
          <doctype><div><span id="child"></span></div></doctype>,
          dict['id' => false],
        ),
      ],
      async ($element, $expected_attributes)[defaults] ==> {
        $doc = await render_to_document_async($element);
        $elem = $doc->getCurrentNode()->getFirstChildx($doc);

        foreach ($expected_attributes as $attr => $expected) {
          expect($elem->hasAttribute($attr))->toEqual($expected);
        }
      },
    );
}
