/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_attribute_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'getAttribute',
      async () ==> dict[
        'can_find_attribute' => tuple(
          <doctype>
            <div id="elem" class="container" data-value="hello"></div>
          </doctype>,
          dict[
            'id' => 'elem',
            'class' => 'container',
            'data-value' => 'hello',
          ],
        ),
        'returns_null_for_missing_attribute' => tuple(
          <doctype>
            <div id="elem"></div>
          </doctype>,
          dict[
            'id' => 'elem',
            'missing-attr' => null,
          ],
        ),
        'empty_attribute_value' => tuple(
          <doctype>
            <div id="elem" data-empty=""></div>
          </doctype>,
          dict[
            'id' => 'elem',
            'data-empty' => '',
          ],
        ),
        'multiple_attributes_on_element' => tuple(
          <doctype>
            <div
              id="elem"
              class="btn btn-primary"
              data-action="click"
              title="Button">
            </div>
          </doctype>,
          dict[
            'id' => 'elem',
            'class' => 'btn btn-primary',
            'data-action' => 'click',
            'title' => 'Button',
          ],
        ),
      ],
      async ($element, $expected_attributes)[defaults] ==> {
        $doc = await render_to_document_async($element);
        $elem = $doc->getElementByIdx('elem');

        foreach ($expected_attributes as $attr_name => $expected_value) {
          $actual_value = $elem->getAttribute($attr_name);
          expect($actual_value)->toEqual($expected_value);
        }
      },
    );
}
