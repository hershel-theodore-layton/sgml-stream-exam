/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStreamExam, TestChain};
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_dataset_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'getDataset',
      async () ==> dict[
        'no_attributes' => tuple(dict[], dict[]),
        'only_data_attributes' => tuple(
          dict['id' => 'elem', 'data' => 'ignored', 'data-id' => '123'],
          dict['id' => '123'],
        ),
        'camel_case_and_string_values' => tuple(
          dict['data-user-id' => '007', 'data-empty' => '', 'data-zero' => '0'],
          dict['userId' => '007', 'empty' => '', 'zero' => '0'],
        ),
        'preserves_other_punctuation_and_non_ascii' => tuple(
          dict[
            'data--foo' => 'a',
            'data-foo--bar' => 'b',
            'data-foo-' => 'c',
            'data-foo-1' => 'd',
            'data-a.b_c:d' => 'e',
            'data-foo-é' => 'f',
            'data-É' => 'g',
          ],
          dict[
            'Foo' => 'a',
            'foo-Bar' => 'b',
            'foo-' => 'c',
            'foo-1' => 'd',
            'a.b_c:d' => 'e',
            'foo-é' => 'f',
            'É' => 'g',
          ],
        ),
        'empty_and_numeric_names' => tuple(
          dict['data-' => 'empty name', 'data-123' => 'numeric name'],
          dict['' => 'empty name', '123' => 'numeric name'],
        ),
        'excludes_ascii_uppercase_attribute_names' => tuple(
          dict['data-fooBar' => 'a', 'DATA-foo' => 'b', 'data-foo-bar' => 'c'],
          dict['fooBar' => 'c'],
        ),
      ],
      async ($attributes, $expected)[defaults] ==> {
        $id = SGMLStreamExam\node_id_from_int(0);
        $node = new SGMLStreamExam\Node($id, $id, 'div', $attributes, 0);

        expect($node->getDataset())->toEqual($expected);
      },
    )
    ->testAsync('rendered_attributes_and_non_elements', async ()[defaults] ==> {
      $doc = await render_to_document_async(
        <doctype>
          <div data-user-id="123" data-value="a & b">
            Text
            <conditional_comment if="IE">Comment</conditional_comment>
            <span data-child="excluded"></span>
          </div>
        </doctype>,
      );
      $root = $doc->getCurrentNode();
      $element = $root->getFirstChildx($doc);

      expect($element->getDataset())
        ->toEqual(dict['userId' => '123', 'value' => 'a & b']);
      expect($root->getDataset())->toEqual(dict[]);
      foreach ($element->getChildren($doc) as $child) {
        if ($child->getNodeType() !== SGMLStreamExam\Node::ELEMENT_NODE) {
          expect($child->getDataset())->toEqual(dict[]);
        }
      }
    });
}
