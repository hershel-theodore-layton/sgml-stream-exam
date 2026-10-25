/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HH\Lib\{C, Vec};
use namespace HTL\{SGMLStreamExam, TestChain};
use function HTL\Expect\expect;
use function HTL\Pragma\pragma;

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
        $subject = $doc->getCurrentNode()->getElementByIdx($doc, $subject_id);
        $other = $doc->getCurrentNode()->getElementByIdx($doc, $other_id);

        $ancestor_ids =
          Vec\map($other->getAncestors($doc), $a ==> $a->getNodeId());
        $expected = $subject_id === $other_id ||
          C\contains($ancestor_ids, $subject->getNodeId());

        expect($subject->contains($doc, $other))->toEqual($expected);
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

        $doctype = $doc->getCurrentNode();

        foreach ($doctype->getDescendantsAndSelf($doc) as $node) {
          expect($doctype->contains($doc, $node))->toBeTrue();
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

        $root = $doc->getCurrentNode();
        $left = $root->getElementByIdx($doc, 'left');
        $right = $root->getElementByIdx($doc, 'right');
        $left_child = $root->getElementByIdx($doc, 'left_child');
        $right_child = $root->getElementByIdx($doc, 'right_child');

        expect($left->contains($doc, $right))->toBeFalse();
        expect($left->contains($doc, $right_child))->toBeFalse();
        expect($right->contains($doc, $left))->toBeFalse();
        expect($right->contains($doc, $left_child))->toBeFalse();
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

        $root = $doc->getCurrentNode();

        foreach ($root->getDescendantsAndSelf($doc) as $node) {
          expect($node->contains($doc, $node))->toBeTrue();
        }
      },
    )
    ->testAsync(
      'separate documents cannot contain each other',
      async ()[defaults] ==> {
        await Vec\map_async(
          vec[
            vec['<div>', 'text', '<!--comment-->', '</div>'],
            vec['<div>', '<span>', 'longer text', '</span>', '</div>'],
          ],
          async $markup ==> {
            $documents = await Vec\map_async(
              vec[vec['<div>', 'text', '<!--comment-->', '</div>'], $markup],
              async $source ==> {
                $consumer = new SGMLStreamExam\ToHTMLDocumentConsumer();
                await $consumer->consumeAsync('<!DOCTYPE html>');
                foreach ($source as $piece) {
                  // Each piece depends on the preceding parser state.
                  pragma('PhaLinters', 'fixme:dont_await_in_a_loop');
                  await $consumer->consumeAsync($piece);
                }
                await $consumer->theDocumentIsCompleteAsync();
                return $consumer->toDocument();
              },
            );
            list($left, $right) = $documents;
            foreach (
              $left->getCurrentNode()->getDescendantsAndSelf($left) as $a
            ) {
              expect($a->contains($left, $a))->toBeTrue();
              foreach (
                $right->getCurrentNode()->getDescendantsAndSelf($right) as $b
              ) {
                expect($a->contains($left, $b))->toBeFalse();
                expect($b->contains($right, $a))->toBeFalse();
              }
            }
          },
        );
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

        $target = $doc->getCurrentNode()->getElementByIdx($doc, 'target');

        foreach ($target->getAncestors($doc) as $ancestor) {
          expect($target->contains($doc, $ancestor))->toBeFalse();
        }
      },
    );
}
