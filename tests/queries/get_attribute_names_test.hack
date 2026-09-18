/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_attribute_names_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'getAttributeNames',
      async () ==> dict[
        'no_attributes' => tuple(
          <doctype><div></div></doctype>,
          vec[],
        ),
        'preserves_rendered_attribute_order' => tuple(
          <doctype>
            <div
              aria-hidden="true"
              id="elem"
              class="container"
              data-action="click"
              title="Button">
            </div>
          </doctype>,
          vec['id', 'class', 'title', 'aria-hidden', 'data-action'],
        ),
        'includes_empty_attribute_values' => tuple(
          <doctype><div class="" data-empty=""></div></doctype>,
          vec['class', 'data-empty'],
        ),
        'only_returns_own_attributes' => tuple(
          <doctype><div><span id="child"></span></div></doctype>,
          vec[],
        ),
      ],
      async ($element, $expected_names)[defaults] ==> {
        $doc = await render_to_document_async($element);
        $elem = $doc->getCurrentNode()->getFirstChildx($doc);

        expect($elem->getAttributeNames())->toEqual($expected_names);
      },
    );
}
