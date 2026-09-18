/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function has_attributes_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'hasAttributes',
      async () ==> dict[
        'no_attributes' => tuple(
          <doctype><div></div></doctype>,
          false,
        ),
        'single_attribute' => tuple(
          <doctype><div id="elem"></div></doctype>,
          true,
        ),
        'multiple_attributes' => tuple(
          <doctype><div id="elem" class="container"></div></doctype>,
          true,
        ),
        'empty_attribute_value' => tuple(
          <doctype><div data-empty=""></div></doctype>,
          true,
        ),
        'boolean_attribute' => tuple(
          <doctype><input autofocus={SET} /></doctype>,
          true,
        ),
        'only_checks_own_attributes' => tuple(
          <doctype><div><span id="child"></span></div></doctype>,
          false,
        ),
      ],
      async ($element, $expected)[defaults] ==> {
        $doc = await render_to_document_async($element);
        $elem = $doc->getCurrentNode()->getFirstChildx($doc);

        expect($elem->hasAttributes())->toEqual($expected);
      },
    );
}
