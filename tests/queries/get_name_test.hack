/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStreamExam, TestChain};
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_name_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testAsync('getName returns element tag name', async ()[defaults] ==> {
      $doc = await render_to_document_async(
        <doctype>
          <div id="div-elem"></div>
        </doctype>,
      );
      $root = $doc->getCurrentNode();

      $div = $root->getElementByIdx($doc, 'div-elem');
      expect($div->getName())->toEqual('div');
    })
    ->testAsync(
      'getName returns correct tag for various elements',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <section id="section-elem"></section>
            <article id="article-elem"></article>
            <span id="span-elem"></span>
            <p id="p-elem"></p>
          </doctype>,
        );
        $root = $doc->getCurrentNode();

        expect($root->getElementByIdx($doc, 'section-elem')->getName())
          ->toEqual('section');
        expect($root->getElementByIdx($doc, 'article-elem')->getName())
          ->toEqual('article');
        expect($root->getElementByIdx($doc, 'span-elem')->getName())
          ->toEqual('span');
        expect($root->getElementByIdx($doc, 'p-elem')->getName())
          ->toEqual('p');
      },
    )
    ->testAsync(
      'getName returns doctype constant for doctype node',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="elem"></div>
          </doctype>,
        );

        $root = $doc->getCurrentNode();
        expect($root->getName())->toEqual(SGMLStreamExam\Node::DOCTYPE);
      },
    )
    ->testAsync(
      'getName returns text node constant for text content',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="parent">Some text content</div>
          </doctype>,
        );
        $root = $doc->getCurrentNode();

        $parent = $root->getElementByIdx($doc, 'parent');
        $text_child = $parent->getFirstChildx($doc);

        expect($text_child->getName())
          ->toEqual(SGMLStreamExam\Node::TXTNODE);
      },
    );
}
