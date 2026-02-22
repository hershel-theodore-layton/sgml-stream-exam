/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_attributes_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'getAttributes',
      async () ==> dict[
        'can_find_all_attributes' => tuple(
          <doctype>
            <div id="elem" class="container" data-value="hello"></div>
          </doctype>,
          dict[
            'id' => 'elem',
            'class' => 'container',
            'data-value' => 'hello',
          ],
        ),
        'includes_empty_attribute_values' => tuple(
          <doctype>
            <div id="elem" data-empty=""></div>
          </doctype>,
          dict[
            'id' => 'elem',
            'data-empty' => '',
          ],
        ),
        'multiple_attributes_all_returned_aria_and_data_last' => tuple(
          <doctype>
            <div
              aria-hidden="true"
              id="elem"
              class="btn btn-primary"
              data-action="click"
              title="Button">
            </div>
          </doctype>,
          dict[
            'id' => 'elem',
            'class' => 'btn btn-primary',
            'title' => 'Button',
            'aria-hidden' => 'true',
            'data-action' => 'click',
          ],
        ),
      ],
      async ($element, $expected_attributes)[defaults] ==> {
        $doc = await render_to_document_async($element);
        $elem = $doc->getElementByIdx('elem');

        $actual_attributes = $elem->getAttributes();
        expect($actual_attributes)->toEqual($expected_attributes);
      },
    );
}
