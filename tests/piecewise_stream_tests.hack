/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStreamInterfaces, TestChain};
use function HTL\Expect\expect;

<<TestChain\Discover>>
function piecewise_stream_tests(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'render',
      async () ==> dict[
        'doctype' => tuple( //
          <doctype />,
          vec['<!DOCTYPE html>'],
        ),
        'without_attributes' => tuple(
          <doctype><div /></doctype>,
          vec['<!DOCTYPE html>', '<div>', '</div>'],
        ),
        'with_attributes' => tuple(
          <doctype>
            <div
              autocorrect="on"
              autofocus={SET}
              class="big"
              hidden={SET}
              id="1234"
              tabindex={-1}
            />
          </doctype>,
          vec[
            '<!DOCTYPE html>',
            '<div autocorrect="on" autofocus class="big" hidden id="1234" tabindex="-1">',
            '</div>',
          ],
        ),
        'nested' => tuple(
          <doctype><div id="outer"><div id="inner" /></div></doctype>,
          vec[
            '<!DOCTYPE html>',
            '<div id="outer">',
            '<div id="inner">',
            '</div>',
            '</div>',
          ],
        ),
        'with_comment' => tuple(
          <doctype>
            <conditional_comment if="IE 8">
              Some text...
            </conditional_comment>
          </doctype>,
          vec[
            '<!DOCTYPE html>',
            '<!--[if IE 8]>',
            ' Some text... ',
            '<![endif]-->',
          ],
        ),
        'void_elements' => tuple(
          <doctype>
            <div><input name="name" placeholder="Enter your name..." /></div>
          </doctype>,
          vec[
            '<!DOCTYPE html>',
            '<div>',
            '<input name="name" placeholder="Enter your name...">',
            '</div>',
          ],
        ),
        'htmlspecialchars' => tuple(
          <doctype><div id={'I <3 "U" :)'}>{'I <3 "U" :)'}</div></doctype>,
          vec[
            '<!DOCTYPE html>',
            '<div id="I &lt;3 &quot;U&quot; :)">',
            'I &lt;3 &quot;U&quot; :)',
            '</div>',
          ],
        ),
        'empty_text_child' => tuple(
          <doctype><div>{''}</div></doctype>,
          vec[
            '<!DOCTYPE html>',
            '<div>',
            '',
            '</div>',
          ],
        ),
        'null_child' => tuple(
          <doctype><div>{null}</div></doctype>,
          vec[
            '<!DOCTYPE html>',
            '<div>',
            '</div>',
          ],
        ),
        'frag_child' => tuple(
          <doctype>
            <div>
              {<frag>{vec['one', <div id="two" />, null, 'four']}</frag>}
            </div>
          </doctype>,
          vec[
            '<!DOCTYPE html>',
            '<div>',
            'one',
            '<div id="two">',
            '</div>',
            'four',
            '</div>',
          ],
        ),
        'dissolvable_element' => tuple(
          <doctype>
            <div id="outer"><Dissolve><div id="child" /></Dissolve></div>
          </doctype>,
          vec[
            '<!DOCTYPE html>',
            '<div id="outer">',
            '<div class="dissolve">',
            '<div id="child">',
            '</div>',
            '</div>',
            '</div>',
          ],
        ),
        'simple_element' => tuple(
          <doctype>
            <div id="outer"><Simple><div id="child" /></Simple></div>
          </doctype>,
          vec[
            '<!DOCTYPE html>',
            '<div id="outer">',
            '<div class="simple">',
            '<div id="child">',
            '</div>',
            '</div>',
            '</div>',
          ],
        ),
        'async_element' => tuple(
          <doctype>
            <div id="outer">
              <Asynchronous><div id="child" /></Asynchronous>
            </div>
          </doctype>,
          vec[
            '<!DOCTYPE html>',
            '<div id="outer">',
            '<div class="async">',
            '<div id="child">',
            '</div>',
            '</div>',
            '</div>',
          ],
        ),
        'successor_element' => tuple(
          <doctype>
            <div id="outer"><Successor><div id="child" /></Successor></div>
          </doctype>,
          vec[
            '<!DOCTYPE html>',
            '<div id="outer">',
            '<div class="successor">',
            '<div id="child">',
            '</div>',
            '</div>',
            '</div>',
          ],
        ),
      ],
      async (
        SGMLStreamInterfaces\Streamable $streamable,
        vec<string> $expected,
      )[defaults] ==> {
        $doc = await render_to_strings_async($streamable);
        expect($doc)->toEqual($expected);
      },
    );
}
