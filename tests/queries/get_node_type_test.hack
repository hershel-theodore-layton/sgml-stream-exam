/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStreamExam, TestChain};
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_node_type_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain
    ->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'getNodeType',
      async () ==> dict[
        'element_node_has_type_1' => tuple(
          <doctype>
            <div id="elem"></div>
          </doctype>,
          SGMLStreamExam\Node::ELEMENT_NODE,
        ),
        'void_element_has_type_1' => tuple(
          <doctype>
            <input id="elem" />
          </doctype>,
          SGMLStreamExam\Node::ELEMENT_NODE,
        ),
        'nested_element_has_type_1' => tuple(
          <doctype>
            <div id="outer">
              <span id="elem"></span>
            </div>
          </doctype>,
          SGMLStreamExam\Node::ELEMENT_NODE,
        ),
      ],
      async ($xhp, $expected)[defaults] ==> {
        $doc = await render_to_document_async($xhp);
        $root = $doc->getCurrentNode();
        $elem = $root->getElementByIdx($doc, 'elem');

        expect($elem->getNodeType())->toEqual($expected);
      },
    )
    ->testAsync(
      'doctype node has node type 10',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="x"></div>
          </doctype>,
        );

        $doctype = $doc->getCurrentNode();
        expect($doctype->getNodeType())->toEqual(
          SGMLStreamExam\Node::DOCUMENT_TYPE_NODE,
        );
      },
    )
    ->testAsync(
      'text node has node type 3',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="parent">Some text</div>
          </doctype>,
        );

        $root = $doc->getCurrentNode();
        $parent = $root->getElementByIdx($doc, 'parent');
        $text_node = $parent->getFirstChildx($doc);

        expect($text_node->getNodeType())->toEqual(
          SGMLStreamExam\Node::TEXT_NODE,
        );
      },
    )
    ->testAsync(
      'comment node has node type 8',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <conditional_comment if="IE 8">
              Some text...
            </conditional_comment>
          </doctype>,
        );

        $doctype = $doc->getCurrentNode();
        $comment = $doctype->getFirstChildx($doc);

        expect($comment->getNodeType())->toEqual(
          SGMLStreamExam\Node::COMMENT_NODE,
        );
      },
    );
}
