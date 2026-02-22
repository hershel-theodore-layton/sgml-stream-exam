/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStreamExam, TestChain};
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_node_value_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain
    ->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'getNodeValue',
      async () ==> dict[
        'element_node_returns_null' => tuple(
          <doctype>
            <div id="elem"></div>
          </doctype>,
          'elem',
        ),
        'void_element_returns_null' => tuple(
          <doctype>
            <input id="elem" />
          </doctype>,
          'elem',
        ),
        'element_with_children_returns_null' => tuple(
          <doctype>
            <div id="elem">
              <span></span>
            </div>
          </doctype>,
          'elem',
        ),
      ],
      async ($xhp, $elem_id)[defaults] ==> {
        $doc = await render_to_document_async($xhp);
        $elem = $doc->getElementByIdx($elem_id);

        expect($elem->getNodeValue($doc))->toBeNull();
      },
    )
    ->testAsync(
      'getNodeValue on the doctype node returns null',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="x"></div>
          </doctype>,
        );

        $doctype = $doc->getRootElement();
        expect($doctype->getNodeValue($doc))->toBeNull();
      },
    )
    ->testAsync(
      'getNodeValue on a text node returns its text content',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="parent">Hello, world!</div>
          </doctype>,
        );

        $parent = $doc->getElementByIdx('parent');
        $text_node = $parent->getFirstChildx();

        expect($text_node->getName())->toEqual(
          SGMLStreamExam\Node::TXTNODE_NAME,
        );
        expect($text_node->getNodeValue($doc))->toEqual('Hello, world!');
      },
    )
    ->testAsync(
      'getNodeValue on a text node preserves surrounding whitespace',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="parent">
              {'  padded  '}
            </div>
          </doctype>,
        );

        $parent = $doc->getElementByIdx('parent');
        expect($parent->getFirstChildx()->getNodeValue($doc))
          ->toEqual('  padded  ');
      },
    )
    ->testAsync(
      'getNodeValue on a comment node returns its content',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <conditional_comment if="IE 8">
              Some text...
            </conditional_comment>
          </doctype>,
        );

        $doctype = $doc->getRootElement();
        $comm = $doctype->getFirstChildx();

        $value = expect($comm->getNodeValue($doc))->toBeNonnull()->getValue();
        expect($value)->toEqual('[if IE 8]> Some text... <![endif]');
      },
    )
    ->testAsync(
      'getNodeValue is consistent with getOuterHTML for text nodes',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="parent">
              <span id="a"></span>
              between
              <span id="b"></span>
            </div>
          </doctype>,
        );

        $parent = $doc->getElementByIdx('parent');
        $children = $parent->getChildren();

        // Middle child is the " between " text node
        $text_node = $children[1];
        expect($text_node->getName())->toEqual(
          SGMLStreamExam\Node::TXTNODE_NAME,
        );
        expect($text_node->getNodeValue($doc))
          ->toEqual($text_node->getOuterHTML($doc));
      },
    );
}
