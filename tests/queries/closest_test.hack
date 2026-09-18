/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStreamExam, TestChain};
use function HTL\Expect\{expect, expect_invoked};

<<TestChain\Discover>>
function closest_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'finds the nearest matching element',
      async () ==> dict[
        'self' => tuple('#leaf', 'leaf'),
        'universal' => tuple('*', 'leaf'),
        'parent' => tuple('.panel', 'inner'),
        'ancestor' => tuple('#outer', 'outer'),
        'list order' => tuple('#outer, .panel', 'inner'),
        'self before ancestor' => tuple('#outer, #leaf', 'leaf'),
        'complex selector' => tuple('#outer > div.panel', 'inner'),
        'root' => tuple(':root', 'outer'),
        'scope self' => tuple(':scope', 'leaf'),
        'scope stays on receiver' => tuple('.panel:scope', null),
        'scope inside not' => tuple('.panel:not(:scope)', 'inner'),
        'scope child' => tuple(':scope > *', null),
        'missing' => tuple('.missing', null),
        'descendant excluded' => tuple('#child', null),
        'sibling excluded' => tuple('#sibling', null),
      ],
      async ($selector, $expected_id)[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="outer" class="panel">
              <div id="inner" class="panel">
                <span id="leaf"><span id="child" /></span>
                <span id="sibling" />
              </div>
            </div>
          </doctype>,
        );
        $root = $doc->getCurrentNode();
        $leaf = $root->getElementByIdx($doc, 'leaf');
        $expected = $expected_id is null
          ? null
          : $root->getElementByIdx($doc, $expected_id);
        expect($leaf->closest($doc, $selector) === $expected)->toBeTrue();
      },
    )
    ->testAsync(
      'non-elements return null and selectors are fully validated',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div>Text<conditional_comment if="IE">Comment</conditional_comment>
            </div>
          </doctype>,
        );
        $root = $doc->getCurrentNode();
        $element = $root->getFirstChildx($doc);
        $nodes = vec[$root, $element];
        foreach ($element->getChildren($doc) as $child) {
          $nodes[] = $child;
        }
        foreach ($nodes as $node) {
          if ($node->getNodeType() !== SGMLStreamExam\Node::ELEMENT_NODE) {
            expect($node->closest($doc, '*'))->toBeNull();
          }
          foreach (vec['', '* , [', ':hover'] as $selector) {
            expect_invoked(() ==> $node->closest($doc, $selector))
              ->toHaveThrown<SGMLStreamExam\InvalidSelectorException>();
          }
        }
      },
    );
}
