/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStreamExam, TestChain};
use type HH\InvariantException;
use function HTL\Expect\{expect, expect_invoked};

<<TestChain\Discover>>
function document_ownership_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testAsync(
      'all document-taking methods reject foreign and unowned nodes',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype><div id="subject">text<span /><!--comment--></div></doctype>,
        );
        $foreign = await render_to_document_async(
          <doctype><div id="subject">text<span /><!--comment--></div></doctype>,
        );
        $root = $doc->getCurrentNode();
        $element = $root->getFirstChildx($doc);
        $id = $element->getNodeId();
        $unowned = new SGMLStreamExam\Node($id, $id, 'div', dict[], 0);
        $nodes = $root->getDescendantsAndSelf($doc);
        $nodes[] = clone $element;
        $nodes[] = $unowned;
        foreach ($nodes as $node) {
          // Identical IDs, offsets and markup cannot establish ownership.
          $operations = vec[
            () ==> $node->getAncestors($foreign),
            () ==> $node->getChildren($foreign),
            () ==> $node->hasChildNodes($foreign),
            () ==> $node->getChildElementCount($foreign),
            () ==> $node->getDescendants($foreign),
            () ==> $node->getDescendantsAndSelf($foreign),
            () ==> $node->getElementById($foreign, ''),
            () ==> $node->getElementByIdx($foreign, ''),
            () ==> $node->getElementsByClassName($foreign, ''),
            () ==> $node->getElementsByTagName($foreign, '*'),
            () ==> $node->getFirstChild($foreign),
            () ==> $node->getFirstElementChild($foreign),
            () ==> $node->getFirstChildx($foreign),
            () ==> $node->getInnerHTML($foreign),
            () ==> $node->getNodeValue($foreign),
            () ==> $node->getTextContent($foreign),
            () ==> $node->getOuterHTML($foreign),
            () ==> $node->getLastChild($foreign),
            () ==> $node->getLastElementChild($foreign),
            () ==> $node->getLastChildx($foreign),
            () ==> $node->getPreviousSibling($foreign),
            () ==> $node->getNextSibling($foreign),
            () ==> $node->getPreviousElementSibling($foreign),
            () ==> $node->getNextElementSibling($foreign),
            () ==> $node->getSiblingsAndSelf($foreign),
            () ==> $node->getParent($foreign),
            () ==> $node->matches($foreign, '*'),
            () ==> $node->closest($foreign, '*'),
            () ==> $node->querySelector($foreign, '*'),
            () ==> $node->querySelectorAll($foreign, '*'),
            () ==> $node->isEqualNode($foreign, null),
            () ==> $node->contains($foreign, $node),
          ];
          foreach ($operations as $operation) {
            expect_invoked($operation)->toHaveThrown<InvariantException>(
              'The document must own this node.',
            );
          }
        }
        foreach (vec[clone $element, $unowned] as $node) {
          expect_invoked(() ==> $node->getParent($doc))
            ->toHaveThrown<InvariantException>(
              'The document must own this node.',
            );
          expect($root->contains($doc, $node))->toBeFalse();
        }
        // Receiver validation also precedes parsing invalid selectors.
        expect_invoked(() ==> $root->matches($foreign, '['))
          ->toHaveThrown<InvariantException>(
            'The document must own this node.',
          );
        expect($element->getParent($doc) === $root)->toBeTrue();
        expect($element->getElementById($doc, ''))->toEqual(null);
        expect($element->getElementsByClassName($doc, ''))->toEqual(vec[]);
      },
    );
}
