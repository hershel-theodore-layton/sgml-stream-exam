/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HH\Lib\{C, Vec};
use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function contains_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain
    ->group(__FUNCTION__)
    ->testWith3ParamsAsync(
      'contains',
      async () ==> dict[
        'node_contains_itself' => tuple(
          <doctype>
            <div id="subject"></div>
          </doctype>,
          'subject',
          'subject',
        ),
        'parent_contains_direct_child' => tuple(
          <doctype>
            <div id="subject">
              <span id="other"></span>
            </div>
          </doctype>,
          'subject',
          'other',
        ),
        'ancestor_contains_deeply_nested_descendant' => tuple(
          <doctype>
            <div id="subject">
              <div>
                <div>
                  <span id="other"></span>
                </div>
              </div>
            </div>
          </doctype>,
          'subject',
          'other',
        ),
        'sibling_does_not_contain_sibling' => tuple(
          <doctype>
            <div id="parent">
              <span id="subject"></span>
              <span id="other"></span>
            </div>
          </doctype>,
          'subject',
          'other',
        ),
        'child_does_not_contain_parent' => tuple(
          <doctype>
            <div id="other">
              <span id="subject"></span>
            </div>
          </doctype>,
          'subject',
          'other',
        ),
        'unrelated_subtrees_do_not_contain_each_other' => tuple(
          <doctype>
            <div id="left">
              <span id="subject"></span>
            </div>
            <div id="right">
              <span id="other"></span>
            </div>
          </doctype>,
          'subject',
          'other',
        ),
        'cousin_does_not_contain_cousin' => tuple(
          <doctype>
            <div id="parent">
              <div>
                <span id="subject"></span>
              </div>
              <div>
                <span id="other"></span>
              </div>
            </div>
          </doctype>,
          'subject',
          'other',
        ),
      ],
      async ($xhp, $subject_id, $other_id)[defaults] ==> {
        $doc = await render_to_document_async($xhp);
        $subject = $doc->getElementByIdx($subject_id);
        $other = $doc->getElementByIdx($other_id);

        $ancestor_ids =
          Vec\map($other->getAncestors($doc), $a ==> $a->getNodeId());
        $expected = $subject_id === $other_id ||
          C\contains($ancestor_ids, $subject->getNodeId());

        expect($subject->contains($other))->toEqual($expected);
      },
    )
    ->testAsync(
      'doctype contains all nodes in the document',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="a">
              <span id="b"></span>
              c
              <span id="d">
                <input id="e" />
              </span>
            </div>
          </doctype>,
        );

        $doctype = $doc->getRootElement();

        foreach ($doctype->traverse() as $node) {
          expect($doctype->contains($node))->toBeTrue();
        }
      },
    )
    ->testAsync(
      'contains returns false for nodes outside the receiver subtree',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="left">
              <span id="left_child"></span>
            </div>
            <div id="right">
              <span id="right_child"></span>
            </div>
          </doctype>,
        );

        $left = $doc->getElementByIdx('left');
        $right = $doc->getElementByIdx('right');
        $left_child = $doc->getElementByIdx('left_child');
        $right_child = $doc->getElementByIdx('right_child');

        expect($left->contains($right))->toBeFalse();
        expect($left->contains($right_child))->toBeFalse();
        expect($right->contains($left))->toBeFalse();
        expect($right->contains($left_child))->toBeFalse();
      },
    )
    ->testAsync(
      'contains is true for every node with respect to itself (text nodes included)',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="a">
              Some text
              <span id="b"></span>
            </div>
          </doctype>,
        );

        $root = $doc->getRootElement();

        foreach ($root->traverse() as $node) {
          expect($node->contains($node))->toBeTrue();
        }
      },
    )
    ->testAsync(
      'child does not contain any of its ancestors',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="a">
              <div id="b">
                <div id="c">
                  <div id="target"></div>
                </div>
              </div>
            </div>
          </doctype>,
        );

        $target = $doc->getElementByIdx('target');

        foreach ($target->getAncestors($doc) as $ancestor) {
          expect($target->contains($ancestor))->toBeFalse();
        }
      },
    );
}
