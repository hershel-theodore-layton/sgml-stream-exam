/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HH\Lib\Str;
use namespace HTL\{SGMLStreamExam, TestChain};
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_attribute_node_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testAsync('lookup preserves original attribute names', async ()[defaults] ==> {
      $id = SGMLStreamExam\node_id_from_int(0);
      $attributes = dict[
        'data-lower' => 'lower',
        'DaTa-Mixed' => 'mixed',
        'ID' => 'elem',
        'CLASS' => 'container',
        'data-É' => 'non-ascii',
      ];
      $node = new SGMLStreamExam\Node($id, $id, 'div', $attributes, 0);
      expect($node->getAttributes())->toEqual($attributes);
      expect($node->getAttributeNames())
        ->toEqual(vec['data-lower', 'DaTa-Mixed', 'ID', 'CLASS', 'data-É']);
      expect($node->getId())->toEqual('elem');
      expect($node->getClassName())->toEqual('container');
      expect($node->getAttribute('DATA-É'))->toEqual('non-ascii');
      expect($node->hasAttribute('data-é'))->toBeFalse();
      $attr = $node->getAttributeNode('DATA-MIXED');
      invariant($attr is nonnull, 'Expected the mixed-case attribute.');
      expect($attr->getName())->toEqual('DaTa-Mixed');
      expect($attr->getValue())->toEqual('mixed');
    })
    ->testAsync('the first case-equivalent attribute wins', async ()[defaults] ==> {
      $id = SGMLStreamExam\node_id_from_int(0);
      $node = new SGMLStreamExam\Node(
        $id,
        $id,
        'div',
        dict['DaTa-Value' => 'first', 'data-value' => 'second'],
        0,
      );
      expect($node->getAttribute('DATA-VALUE'))->toEqual('first');
      expect($node->getAttributes())->toEqual(dict['DaTa-Value' => 'first']);
    })
    ->testWith2ParamsAsync(
      'getAttributeNode',
      async () ==> dict[
        'name_and_value' => tuple('data-value', 'hello'),
        'empty_value' => tuple('data-empty', ''),
        'zero_value' => tuple('data-zero', '0'),
        'missing_attribute' => tuple('missing', null),
        'empty_name' => tuple('', null),
        'case_insensitive_lookup' => tuple('DATA-VALUE', 'hello'),
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
          expect($attr->getName())->toEqual(Str\lowercase($name));
          expect($attr->getValue())->toEqual($expected_value);
        }
      },
    );
}
