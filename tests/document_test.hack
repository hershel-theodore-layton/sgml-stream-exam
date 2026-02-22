/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{ExprDump, SGMLStreamInterfaces, TestChain};
use function HTL\Expect\expect;

<<TestChain\Discover>>
function document_test(TestChain\Chain $chain)[]: TestChain\Chain {
  $dumper = ExprDump\create_dumper<mixed>(shape());

  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'render',
      async () ==> dict[
        'doctype' => tuple( //
          <doctype />,
          dict[
            'outerHTML' => '<!DOCTYPE html>',
            'name' => '!DOCTYPE',
            'attributes' => dict[],
            'children' => vec[],
          ],
        ),
        'without_attributes' => tuple(
          <doctype><div /></doctype>,
          dict[
            'outerHTML' => '<!DOCTYPE html>',
            'name' => '!DOCTYPE',
            'attributes' => dict[],
            'children' => vec[dict[
              'outerHTML' => '<div></div>',
              'name' => 'div',
              'attributes' => dict[],
              'children' => vec[],
            ]],
          ],
        ),
        'with_attributes' => tuple(
          <doctype>
            <div
              autocorrect="on"
              class="big"
              hidden={SET}
              id="1234"
              tabindex={-1}
              autofocus={SET}
            />
          </doctype>,
          dict[
            'outerHTML' => '<!DOCTYPE html>',
            'name' => '!DOCTYPE',
            'attributes' => dict[],
            'children' => vec[dict[
              'outerHTML' =>
                '<div autocorrect="on" class="big" hidden id="1234" tabindex="-1" autofocus></div>',
              'name' => 'div',
              'attributes' => dict[
                'autocorrect' => 'on',
                'class' => 'big',
                'hidden' => '',
                'id' => '1234',
                'tabindex' => '-1',
                'autofocus' => '',
              ],
              'children' => vec[],
            ]],
          ],
        ),
        'nested' => tuple(
          <doctype><div id="outer"><div id="inner" /></div></doctype>,
          dict[
            'outerHTML' => '<!DOCTYPE html>',
            'name' => '!DOCTYPE',
            'attributes' => dict[],
            'children' => vec[dict[
              'outerHTML' => '<div id="outer"><div id="inner"></div></div>',
              'name' => 'div',
              'attributes' => dict['id' => 'outer'],
              'children' => vec[dict[
                'outerHTML' => '<div id="inner"></div>',
                'name' => 'div',
                'attributes' => dict['id' => 'inner'],
                'children' => vec[],
              ]],
            ]],
          ],
        ),
        'with_comment' => tuple(
          <doctype>
            <conditional_comment if="IE 8">
              Some text...
            </conditional_comment>
          </doctype>,
          dict[
            'outerHTML' => '<!DOCTYPE html>',
            'name' => '!DOCTYPE',
            'attributes' => dict[],
            'children' => vec[dict[
              'outerHTML' => '<!--[if IE 8]> Some text... <![endif]-->',
              'name' => '!COMMENT',
              'attributes' => dict[],
              'children' => vec[],
            ]],
          ],
        ),
        'void_elements' => tuple(
          <doctype>
            <div><input name="name" placeholder="Enter your name..." /></div>
          </doctype>,
          dict[
            'outerHTML' => '<!DOCTYPE html>',
            'name' => '!DOCTYPE',
            'attributes' => dict[],
            'children' => vec[dict[
              'outerHTML' =>
                '<div><input name="name" placeholder="Enter your name..."></div>',
              'name' => 'div',
              'attributes' => dict[],
              'children' => vec[dict[
                'outerHTML' =>
                  '<input name="name" placeholder="Enter your name...">',
                'name' => 'input',
                'attributes' => dict[
                  'name' => 'name',
                  'placeholder' => 'Enter your name...',
                ],
                'children' => vec[],
              ]],
            ]],
          ],
        ),
        'htmlspecialchars' => tuple(
          <doctype><div id={'I <3 "U" :)'}>{'I <3 "U" :)'}</div></doctype>,
          dict[
            'outerHTML' => '<!DOCTYPE html>',
            'name' => '!DOCTYPE',
            'attributes' => dict[],
            'children' => vec[dict[
              'outerHTML' =>
                '<div id="I &lt;3 &quot;U&quot; :)">I &lt;3 &quot;U&quot; :)</div>',
              'name' => 'div',
              'attributes' => dict['id' => 'I <3 "U" :)'],
              'children' => vec[dict[
                'outerHTML' => 'I &lt;3 &quot;U&quot; :)',
                'name' => '!TXTNODE',
                'attributes' => dict[],
                'children' => vec[],
              ]],
            ]],
          ],
        ),
        'empty_text_child' => tuple(
          <doctype><div>{''}</div></doctype>,
          dict[
            'outerHTML' => '<!DOCTYPE html>',
            'name' => '!DOCTYPE',
            'attributes' => dict[],
            'children' => vec[dict[
              'outerHTML' => '<div></div>',
              'name' => 'div',
              'attributes' => dict[],
              'children' => vec[dict[
                'outerHTML' => '',
                'name' => '!TXTNODE',
                'attributes' => dict[],
                'children' => vec[],
              ]],
            ]],
          ],
        ),
        'null_child' => tuple(
          <doctype><div>{null}</div></doctype>,
          dict[
            'outerHTML' => '<!DOCTYPE html>',
            'name' => '!DOCTYPE',
            'attributes' => dict[],
            'children' => vec[dict[
              'outerHTML' => '<div></div>',
              'name' => 'div',
              'attributes' => dict[],
              'children' => vec[],
            ]],
          ],
        ),
        'frag_child' => tuple(
          <doctype>
            <div>
              {<frag>{vec['one', <div id="two" />, null, 'four']}</frag>}
            </div>
          </doctype>,

          dict[
            'outerHTML' => '<!DOCTYPE html>',
            'name' => '!DOCTYPE',
            'attributes' => dict[],
            'children' => vec[dict[
              'outerHTML' => '<div>one<div id="two"></div>four</div>',
              'name' => 'div',
              'attributes' => dict[],
              'children' => vec[
                dict[
                  'outerHTML' => 'one',
                  'name' => '!TXTNODE',
                  'attributes' => dict[],
                  'children' => vec[],
                ],
                dict[
                  'outerHTML' => '<div id="two"></div>',
                  'name' => 'div',
                  'attributes' => dict['id' => 'two'],
                  'children' => vec[],
                ],
                dict[
                  'outerHTML' => 'four',
                  'name' => '!TXTNODE',
                  'attributes' => dict[],
                  'children' => vec[],
                ],
              ],
            ]],
          ],
        ),
        'dissolvable_element' => tuple(
          <doctype>
            <div id="outer"><Dissolve><div id="child" /></Dissolve></div>
          </doctype>,

          dict[
            'outerHTML' => '<!DOCTYPE html>',
            'name' => '!DOCTYPE',
            'attributes' => dict[],
            'children' => vec[dict[
              'outerHTML' =>
                '<div id="outer"><div class="dissolve"><div id="child"></div></div></div>',
              'name' => 'div',
              'attributes' => dict['id' => 'outer'],
              'children' => vec[dict[
                'outerHTML' =>
                  '<div class="dissolve"><div id="child"></div></div>',
                'name' => 'div',
                'attributes' => dict['class' => 'dissolve'],
                'children' => vec[dict[
                  'outerHTML' => '<div id="child"></div>',
                  'name' => 'div',
                  'attributes' => dict['id' => 'child'],
                  'children' => vec[],
                ]],
              ]],
            ]],
          ],
        ),
        'simple_element' => tuple(
          <doctype>
            <div id="outer"><Simple><div id="child" /></Simple></div>
          </doctype>,
          dict[
            'outerHTML' => '<!DOCTYPE html>',
            'name' => '!DOCTYPE',
            'attributes' => dict[],
            'children' => vec[dict[
              'outerHTML' =>
                '<div id="outer"><div class="simple"><div id="child"></div></div></div>',
              'name' => 'div',
              'attributes' => dict['id' => 'outer'],
              'children' => vec[dict[
                'outerHTML' =>
                  '<div class="simple"><div id="child"></div></div>',
                'name' => 'div',
                'attributes' => dict['class' => 'simple'],
                'children' => vec[dict[
                  'outerHTML' => '<div id="child"></div>',
                  'name' => 'div',
                  'attributes' => dict['id' => 'child'],
                  'children' => vec[],
                ]],
              ]],
            ]],
          ],
        ),
        'async_element' => tuple(
          <doctype>
            <div id="outer">
              <Asynchronous><div id="child" /></Asynchronous>
            </div>
          </doctype>,

          dict[
            'outerHTML' => '<!DOCTYPE html>',
            'name' => '!DOCTYPE',
            'attributes' => dict[],
            'children' => vec[dict[
              'outerHTML' =>
                '<div id="outer"><div class="async"><div id="child"></div></div></div>',
              'name' => 'div',
              'attributes' => dict['id' => 'outer'],
              'children' => vec[dict[
                'outerHTML' =>
                  '<div class="async"><div id="child"></div></div>',
                'name' => 'div',
                'attributes' => dict['class' => 'async'],
                'children' => vec[dict[
                  'outerHTML' => '<div id="child"></div>',
                  'name' => 'div',
                  'attributes' => dict['id' => 'child'],
                  'children' => vec[],
                ]],
              ]],
            ]],
          ],
        ),
        'successor_element' => tuple(
          <doctype>
            <div id="outer"><Successor><div id="child" /></Successor></div>
          </doctype>,

          dict[
            'outerHTML' => '<!DOCTYPE html>',
            'name' => '!DOCTYPE',
            'attributes' => dict[],
            'children' => vec[dict[
              'outerHTML' =>
                '<div id="outer"><div class="successor"><div id="child"></div></div></div>',
              'name' => 'div',
              'attributes' => dict['id' => 'outer'],
              'children' => vec[dict[
                'outerHTML' =>
                  '<div class="successor"><div id="child"></div></div>',
                'name' => 'div',
                'attributes' => dict['class' => 'successor'],
                'children' => vec[dict[
                  'outerHTML' => '<div id="child"></div>',
                  'name' => 'div',
                  'attributes' => dict['id' => 'child'],
                  'children' => vec[],
                ]],
              ]],
            ]],
          ],
        ),
      ],
      async (
        SGMLStreamInterfaces\Streamable $streamable,
        $expected,
      )[defaults] ==> {
        $doc = await render_to_document_async($streamable);

        expect($dumper->dump($doc->getRootElement()->toUnitTestDump($doc)))
          ->toEqual($dumper->dump($expected));
      },
    );
}
