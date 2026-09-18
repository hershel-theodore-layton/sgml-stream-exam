/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_attribute_node_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'getAttributeNode',
      async () ==> dict[
        'name_and_value' => tuple('data-value', 'hello'),
        'empty_value' => tuple('data-empty', ''),
        'zero_value' => tuple('data-zero', '0'),
        'missing_attribute' => tuple('missing', null),
        'empty_name' => tuple('', null),
        'matches_get_attribute_case_sensitivity' => tuple('DATA-VALUE', null),
      ],
      async ($name, $expected_value)[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div
              id="elem"
              data-value="hello"
              data-empty=""
              data-zero="0">
            </div>
          </doctype>,
        );
        $elem = $doc->getCurrentNode()->getElementByIdx($doc, 'elem');
        $attr = $elem->getAttributeNode($name);

        if ($expected_value is null) {
          expect($attr)->toEqual(null);
        } else {
          invariant($attr is nonnull, 'Expected an attribute pair.');
          expect($attr->getName())->toEqual($name);
          expect($attr->getValue())->toEqual($expected_value);
        }
      },
    );
}
