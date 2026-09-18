/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStreamExam, TestChain};
use function HTL\Expect\expect;

<<TestChain\Discover>>
function escaped_text_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'text APIs decode character references like the browser DOM',
      async () ==> dict[
        'element_text_content' => tuple('element_text_content', 'A & B'),
        'text_node_text_content' => tuple('text_node_text_content', 'A & B'),
        'text_node_value' => tuple('text_node_value', 'A & B'),
      ],
      async ($operation, $expected)[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype><div id="node">{'A & B'}</div></doctype>,
        );
        $node = $doc->getCurrentNode()->getElementByIdx($doc, 'node');

        // Serialization must stay escaped; only the DOM text APIs decode it.
        expect($node->getOuterHTML($doc))
          ->toEqual('<div id="node">A &amp; B</div>');

        $text = $node->getFirstChildx($doc);
        $actual = $operation === 'element_text_content'
          ? $node->getTextContent($doc)
          : (
              $operation === 'text_node_text_content'
                ? $text->getTextContent($doc)
                : $text->getNodeValue($doc)
            );
        expect($actual)->toEqual($expected);
      },
    )
    ->testAsync('rendered text is decoded exactly once', async ()[defaults] ==> {
      $value = "<b>\"' &amp; &lt; &#169; &nbsp; ©😀</b>";
      $doc = await render_to_document_async(
        <doctype><div>{$value}</div></doctype>,
      );
      $node = $doc->getCurrentNode()->getFirstChildx($doc);
      expect($node->getTextContent($doc))->toEqual($value);
      expect($node->getFirstChildx($doc)->getNodeValue($doc))->toEqual($value);
    })
    ->testWith3ParamsAsync(
      'text decoding respects the parsing context',
      async () ==> dict[
        'decode_once' => tuple('div', '&amp;amp;', '&amp;'),
        'escaped_markup' => tuple('div', '&lt;b&gt;Hi&lt;/b&gt;', '<b>Hi</b>'),
        'quotes' => tuple('div', '&quot;&#039;', "\"'"),
        'unicode' => tuple('div', "\u{00a0}©😀", "\u{00a0}©😀"),
        'textarea' => tuple('textarea', 'A &amp; B', 'A & B'),
        'title' => tuple('title', 'A &amp; B', 'A & B'),
        'script' => tuple('script', 'A &amp; B', 'A &amp; B'),
        'style' => tuple('style', 'A &amp; B', 'A &amp; B'),
      ],
      async ($tag, $source, $expected)[defaults] ==> {
        $consumer = new SGMLStreamExam\ToHTMLDocumentConsumer();
        await $consumer->consumeAsync('<!DOCTYPE html>');
        await $consumer->consumeAsync('<'.$tag.'>');
        await $consumer->consumeAsync($source);
        await $consumer->consumeAsync('</'.$tag.'>');
        await $consumer->theDocumentIsCompleteAsync();
        $doc = $consumer->toDocument();
        $node = $doc->getCurrentNode()->getFirstChildx($doc);
        $text = $node->getFirstChildx($doc);
        expect($node->getInnerHTML($doc))->toEqual($source);
        expect($node->getTextContent($doc))->toEqual($expected);
        expect($text->getTextContent($doc))->toEqual($expected);
        expect($text->getNodeValue($doc))->toEqual($expected);
      },
    )
    ->testAsync(
      'comments remain literal and are excluded from element text',
      async ()[defaults] ==> {
        $consumer = new SGMLStreamExam\ToHTMLDocumentConsumer();
        await $consumer->consumeAsync('<!DOCTYPE html>');
        await $consumer->consumeAsync('<div>');
        await $consumer->consumeAsync('A &amp; B');
        await $consumer->consumeAsync('<!--&amp;-->');
        await $consumer->consumeAsync('<span>');
        await $consumer->consumeAsync('&amp;amp;');
        await $consumer->consumeAsync('</span>');
        await $consumer->consumeAsync('</div>');
        await $consumer->theDocumentIsCompleteAsync();
        $doc = $consumer->toDocument();
        $node = $doc->getCurrentNode()->getFirstChildx($doc);
        expect($node->getTextContent($doc))->toEqual('A & B&amp;');
        $comment = $node->getChildren($doc)[1];
        expect($comment->getTextContent($doc))->toEqual('&amp;');
        expect($comment->getNodeValue($doc))->toEqual('&amp;');
      },
    );
}
