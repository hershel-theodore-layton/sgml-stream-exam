/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

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

      $parent = $doc->getElementByIdx('parent');
      $first_child = $parent->getFirstChild();

      $first_child = expect($first_child)->toBeNonnull()->getValue();
      expect($first_child->getId())->toEqual('first');
    })
    ->testAsync(
      'getFirstChild returns null for element with no children',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="empty"></div>
          </doctype>,
        );

        $empty = $doc->getElementByIdx('empty');
        expect($empty->getFirstChild())->toBeNull();
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

        $parent = $doc->getElementByIdx('parent');
        $first_child = $parent->getFirstChild();

        expect($first_child)->toBeNonnull();
        $first_child as nonnull;
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

      $parent = $doc->getElementByIdx('parent');
      $last_child = $parent->getLastChild();

      expect($last_child)->toBeNonnull();
      $last_child as nonnull;
      expect($last_child->getId())->toEqual('last');
    })
    ->testAsync(
      'getLastChild returns null for element with no children',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="empty"></div>
          </doctype>,
        );

        $empty = $doc->getElementByIdx('empty');
        expect($empty->getLastChild())->toBeNull();
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

        $parent = $doc->getElementByIdx('parent');
        $last_child = $parent->getLastChild();

        $last_child = expect($last_child)->toBeNonnull()->getValue();
        expect($last_child->getOuterHTML($doc))->toEqual(' Some text ');
      },
    );
}
