/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HH\Lib\Vec;
use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_ancestors_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain
    ->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'getAncestors',
      async () ==> dict[
        'doctype is the great ancestor' => tuple( //
          <doctype>
            <div id="target" />
          </doctype>,
          vec[''],
        ),
        'keep asking for parent until doctype' => tuple(
          <doctype>
            <input id="red herring" />
            <div id="a">
              <div id="b">
                <div id="c">
                  <div id="target" />
                </div>
                <div id="blue herring" />
              </div>
            </div>
          </doctype>,
          vec['c', 'b', 'a', ''],
        ),
      ],
      async ($xhp, $expected)[defaults] ==> {
        $doc = await render_to_document_async($xhp);

        $node = $doc->getElementByIdx('target');
        expect(Vec\map($node->getAncestors($doc), $x ==> $x->getId()))
          ->toEqual($expected);
      },
    );
}
