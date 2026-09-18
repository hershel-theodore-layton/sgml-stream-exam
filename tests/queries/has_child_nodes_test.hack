/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function has_child_nodes_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'hasChildNodes',
      async () ==> dict[
        'no_children' => tuple(
          <doctype><div></div></doctype>,
          false,
        ),
        'attributes_are_not_children' => tuple(
          <doctype><div id="elem" class="container"></div></doctype>,
          false,
        ),
        'void_element' => tuple(
          <doctype><input /></doctype>,
          false,
        ),
        'element_child' => tuple(
          <doctype><div><span></span></div></doctype>,
          true,
        ),
        'text_child' => tuple(
          <doctype><div>Only text</div></doctype>,
          true,
        ),
        'comment_child' => tuple(
          <doctype>
            <div>
              <conditional_comment if="IE">Comment</conditional_comment>
            </div>
          </doctype>,
          true,
        ),
        'mixed_children' => tuple(
          <doctype><div>Text<span></span>More text</div></doctype>,
          true,
        ),
        'text_node_has_no_children' => tuple(
          <doctype>Only text</doctype>,
          false,
        ),
        'comment_node_has_no_children' => tuple(
          <doctype>
            <conditional_comment if="IE">Comment</conditional_comment>
          </doctype>,
          false,
        ),
      ],
      async ($element, $expected)[defaults] ==> {
        $doc = await render_to_document_async($element);
        $node = $doc->getCurrentNode()->getFirstChildx($doc);

        expect($node->hasChildNodes($doc))->toEqual($expected);
      },
    );
}
