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

      $div = $doc->getElementByIdx('div-elem');
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

        expect($doc->getElementByIdx('section-elem')->getName())
          ->toEqual('section');
        expect($doc->getElementByIdx('article-elem')->getName())
          ->toEqual('article');
        expect($doc->getElementByIdx('span-elem')->getName())
          ->toEqual('span');
        expect($doc->getElementByIdx('p-elem')->getName())
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

        $root = $doc->getRootElement();
        expect($root->getName())->toEqual(SGMLStreamExam\Node::DOCTYPE_NAME);
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

        $parent = $doc->getElementByIdx('parent');
        $text_child = $parent->getFirstChildx();

        expect($text_child->getName())
          ->toEqual(SGMLStreamExam\Node::TXTNODE_NAME);
      },
    );
}
