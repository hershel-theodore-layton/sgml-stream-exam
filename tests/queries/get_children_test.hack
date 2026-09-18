/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HH\Lib\Vec;
use namespace HTL\{SGMLStreamExam, TestChain};
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_children_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testAsync('merged text keeps tree boundaries and node IDs', async ()[defaults] ==> {
      $consumer = new SGMLStreamExam\ToHTMLDocumentConsumer();
      await $consumer->consumeAsync('<!DOCTYPE html>');
      await $consumer->consumeAsync('<div>');
      await $consumer->consumeAsync('');
      await $consumer->consumeAsync('a');
      await $consumer->consumeAsync('');
      await $consumer->consumeAsync('&amp;');
      await $consumer->consumeAsync('b');
      await $consumer->consumeAsync('<!--comment-->');
      await $consumer->consumeAsync('c');
      await $consumer->consumeAsync('d');
      await $consumer->consumeAsync('<span>');
      await $consumer->consumeAsync('e');
      await $consumer->consumeAsync('f');
      await $consumer->consumeAsync('</span>');
      await $consumer->consumeAsync('g');
      await $consumer->consumeAsync('h');
      await $consumer->consumeAsync('</div>');
      await $consumer->theDocumentIsCompleteAsync();
      $doc = $consumer->toDocument();
      $root = $doc->getCurrentNode();
      $parent = $root->getFirstChildx($doc);
      $children = $parent->getChildren($doc);
      expect(Vec\map($children, $n ==> $n->getOuterHTML($doc)))
        ->toEqual(vec['a&amp;b', '<!--comment-->', 'cd', '<span>ef</span>', 'gh']);
      expect($parent->getTextContent($doc))->toEqual('a&bcdefgh');
      expect($parent->getFirstChildx($doc)->getNodeValue($doc))->toEqual('a&b');
      expect($parent->getLastChildx($doc)->getNodeValue($doc))->toEqual('gh');
      expect($children[0]->getNextSibling($doc))->toEqual($children[1]);
      expect($children[4]->getPreviousSibling($doc))->toEqual($children[3]);
      expect($children[3]->getFirstChildx($doc)->getNodeValue($doc))->toEqual('ef');
      foreach ($root->getDescendantsAndSelf($doc) as $i => $node) {
        expect($node->getNodeId())->toEqual(SGMLStreamExam\node_id_from_int($i));
        expect($doc->getByNodeIdx($node->getNodeId()))->toEqual($node);
      }
    })
    ->testWith2ParamsAsync(
      'getChildren',
      async () ==> dict[
        'adjacent_rendered_strings_form_one_text_node' => tuple(
          <doctype><div id="parent">{'a'}{'b'}</div></doctype>,
          vec['ab'],
        ),
        'can_find_element_children' => tuple(
          <doctype>
            <div id="parent">
              <span id="child1"></span>
              <span id="child2"></span>
              <span id="child3"></span>
            </div>
          </doctype>,
          vec[
            '<span id="child1"></span>',
            '<span id="child2"></span>',
            '<span id="child3"></span>',
          ],
        ),
        'empty_children' => tuple(
          <doctype>
            <div id="parent"></div>
          </doctype>,
          vec[],
        ),
        'single_child' => tuple(
          <doctype>
            <div id="parent"><span id="child1"></span></div>
          </doctype>,
          vec[
            '<span id="child1"></span>',
          ],
        ),
        'mixed_children' => tuple(
          <doctype>
            <div id="parent">
              Some text
              <span id="child1"></span>
              More text
              <span id="child2"></span>
            </div>
          </doctype>,
          vec[
            ' Some text ',
            '<span id="child1"></span>',
            ' More text ',
            '<span id="child2"></span>',
          ],
        ),
      ],
      async ($element, $expected)[defaults] ==> {
        $doc = await render_to_document_async($element);
        $root = $doc->getCurrentNode();
        $parent = $root->getElementByIdx($doc, 'parent');

        $actual =
          Vec\map($parent->getChildren($doc), $c ==> $c->getOuterHTML($doc));
        expect($actual)->toEqual($expected);
      },
    );
}
