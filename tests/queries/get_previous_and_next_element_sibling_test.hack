/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;
use function HTL\Pragma\pragma;

<<TestChain\Discover>>
function get_next_and_previous_element_sibling_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith4ParamsAsync(
      'getNextElementSibling / getPreviousElementSibling',
      async ()[defaults] ==> {
        $fixtures = dict[
          'adjacent_elements_and_boundaries' => tuple(
            <doctype>
              <div>
                <span id="a"></span>
                <span id="b"></span>
                <span id="c"></span>
              </div>
            </doctype>,
            dict[
              'a' => tuple(null, 'b'),
              'b' => tuple('a', 'c'),
              'c' => tuple('b', null),
            ],
          ),
          'skips_text_and_comments' => tuple(
            <doctype>
              <div>
                Leading text
                <conditional_comment if="IE">Before</conditional_comment>
                <span id="a"></span>
                Text
                <conditional_comment if="IE">Between</conditional_comment>
                <span id="b"></span>
                <conditional_comment if="IE">Between</conditional_comment>
                More text
                <span id="c"></span>
                <conditional_comment if="IE">After</conditional_comment>
                Trailing text
              </div>
            </doctype>,
            dict[
              'a' => tuple(null, 'b'),
              'b' => tuple('a', 'c'),
              'c' => tuple('b', null),
            ],
          ),
          'single_child' => tuple(
            <doctype><div><span id="only"></span></div></doctype>,
            dict['only' => tuple(null, null)],
          ),
          'only_non_element_siblings' => tuple(
            <doctype>
              <div>
                Text
                <span id="only"></span>
                <conditional_comment if="IE">Comment</conditional_comment>
              </div>
            </doctype>,
            dict['only' => tuple(null, null)],
          ),
          'stays_within_parent_and_skips_descendants' => tuple(
            <doctype>
              <div>
                <span id="a"><span id="nested-a"></span></span>
                <span id="b"><span id="nested-b"></span></span>
              </div>
            </doctype>,
            dict[
              'a' => tuple(null, 'b'),
              'b' => tuple('a', null),
              'nested-a' => tuple(null, null),
              'nested-b' => tuple(null, null),
            ],
          ),
        ];
        $cases = dict[];
        foreach ($fixtures as $fixture => list($element, $expected_siblings)) {
          // XHP elements are single-use; render each fixture once for its cases.
          pragma('PhaLinters', 'fixme:dont_await_in_a_loop');
          $doc = await render_to_document_async($element);
          foreach ($expected_siblings as $id => list($previous, $next)) {
            $cases[$fixture.' '.$id] = tuple($doc, $id, $previous, $next);
          }
        }
        return $cases;
      },
      async ($doc, string $id, ?string $previous, ?string $next)[defaults] ==> {
        $root = $doc->getCurrentNode();
        $subject = $root->getElementByIdx($doc, $id);
        expect($subject->getPreviousElementSibling($doc)?->getId())->toEqual(
          $previous,
        );
        expect($subject->getNextElementSibling($doc)?->getId())->toEqual($next);
        expect($root->getPreviousElementSibling($doc))->toBeNull();
        expect($root->getNextElementSibling($doc))->toBeNull();
      },
    );
}
