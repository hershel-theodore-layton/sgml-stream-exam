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
        $elem = $doc->getElementByIdx('elem');

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

        $doctype = $doc->getRootElement();
        expect($doctype->getNodeType())->toEqual(
          SGMLStreamExam\Node::DOCTYPE_NODE,
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

        $parent = $doc->getElementByIdx('parent');
        $text_node = $parent->getFirstChildx();

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

        $doctype = $doc->getRootElement();
        $comment = $doctype->getFirstChildx();

        expect($comment->getNodeType())->toEqual(
          SGMLStreamExam\Node::COMMENT_NODE,
        );
      },
    );
}
