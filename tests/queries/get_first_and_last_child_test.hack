/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\{expect, expect_invoked};

<<TestChain\Discover>>
function get_first_and_last_child_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testAsync('getFirstChild', async ()[defaults] ==> {
      $doc = await render_to_document_async(
        <doctype>
          <div id="parent">
            <span id="first"></span>
            <span id="middle"></span>
            <span id="last"></span>
          </div>
        </doctype>,
      );
      $root = $doc->getCurrentNode();

      $parent = $root->getElementByIdx($doc, 'parent');
      $first_child = $parent->getFirstChild($doc);

      $first_child = expect($first_child)->toBeNonnull()->getValue();
      expect($first_child->getId())->toEqual('first');
      expect($parent->getFirstChildx($doc))->toEqual($parent->getFirstChild($doc));
    })
    ->testAsync(
      'getFirstChild returns null for element with no children',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="empty"></div>
          </doctype>,
        );
        $root = $doc->getCurrentNode();

        $empty = $root->getElementByIdx($doc, 'empty');
        expect($empty->getFirstChild($doc))->toBeNull();
        expect_invoked(() ==> $empty->getFirstChildx($doc))
          ->toHaveThrown<InvariantException>(
            'May not call getFirstChildx on a Node with zero children.',
          );
      },
    )
    ->testAsync(
      'getFirstChild with text and element children',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="parent">
              Some text
              <span id="elem"></span>
            </div>
          </doctype>,
        );
        $root = $doc->getCurrentNode();

        $parent = $root->getElementByIdx($doc, 'parent');
        $first_child = $parent->getFirstChild($doc);

        $first_child = expect($first_child)->toBeNonnull()->getValue();
        expect($first_child->getOuterHTML($doc))->toEqual(' Some text ');
      },
    )
    ->testAsync('getLastChild', async ()[defaults] ==> {
      $doc = await render_to_document_async(
        <doctype>
          <div id="parent">
            <span id="first"></span>
            <span id="middle"></span>
            <span id="last"></span>
          </div>
        </doctype>,
      );
      $root = $doc->getCurrentNode();

      $parent = $root->getElementByIdx($doc, 'parent');
      $last_child = $parent->getLastChild($doc);

      $last_child = expect($last_child)->toBeNonnull()->getValue();
      expect($last_child->getId())->toEqual('last');
      expect($parent->getLastChildx($doc))->toEqual($parent->getLastChild($doc));
    })
    ->testAsync(
      'getLastChild returns null for element with no children',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="empty"></div>
          </doctype>,
        );
        $root = $doc->getCurrentNode();

        $empty = $root->getElementByIdx($doc, 'empty');
        expect($empty->getLastChild($doc))->toBeNull();
        expect_invoked(() ==> $empty->getLastChildx($doc))
          ->toHaveThrown<InvariantException>(
            'May not call getLastChildx on a Node with zero children.',
          );
      },
    )
    ->testAsync(
      'getLastChild with text and element children',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="parent">
              <span id="elem"></span>
              Some text
            </div>
          </doctype>,
        );
        $root = $doc->getCurrentNode();

        $parent = $root->getElementByIdx($doc, 'parent');
        $last_child = $parent->getLastChild($doc);

        $last_child = expect($last_child)->toBeNonnull()->getValue();
        expect($last_child->getOuterHTML($doc))->toEqual(' Some text ');
      },
    );
}
