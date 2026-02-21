/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function piecewise_stream_tests(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testAsync('doctype', async ()[defaults] ==> {
      expect(await render_to_strings_async(<doctype />))
        ->toEqual(vec['<!DOCTYPE html>']);
    })
    ->testAsync('without_attributes', async ()[defaults] ==> {
      expect(await render_to_strings_async(<div />))->toEqual(
        vec['<div>', '</div>'],
      );
    })
    ->testAsync('with_attributes', async ()[defaults] ==> {
      expect(await render_to_strings_async(
        <div
          autocorrect="on"
          autofocus={SET}
          class="big"
          hidden={SET}
          id="1234"
          tabindex={-1}
        />,
      ))->toEqual(vec[
        '<div autocorrect="on" autofocus class="big" hidden id="1234" tabindex="-1">',
        '</div>',
      ]);
    })
    ->testAsync('nested', async ()[defaults] ==> {
      expect(
        await render_to_strings_async(<div id="outer"><div id="inner" /></div>),
      )->toEqual(vec[
        '<div id="outer">',
        '<div id="inner">',
        '</div>',
        '</div>',
      ]);
    })
    ->testAsync('with_comment', async ()[defaults] ==> {
      expect(await render_to_strings_async(
        <conditional_comment if="if IE 8">
          Some text...
        </conditional_comment>,
      ))->toEqual(vec[
        '<!--[if if IE 8]>',
        ' Some text... ',
        '<![endif]-->',
      ]);
    })
    ->testAsync('void_elements', async ()[defaults] ==> {
      expect(await render_to_strings_async(
        <div><input name="name" placeholder="Enter your name..." /></div>,
      ))->toEqual(vec[
        '<div>',
        '<input name="name" placeholder="Enter your name...">',
        '</div>',
      ]);
    })
    ->testAsync('htmlspecialchars', async ()[defaults] ==> {
      $text = 'I <3 "U" :)';
      expect(await render_to_strings_async(<div id={$text}>{$text}</div>))
        ->toEqual(vec[
          '<div id="I &lt;3 &quot;U&quot; :)">',
          'I &lt;3 &quot;U&quot; :)',
          '</div>',
        ]);
    })
    ->testAsync('empty_text_child', async ()[defaults] ==> {
      $text = '';
      expect(await render_to_strings_async(<div>{$text}</div>))
        ->toEqual(vec[
          '<div>',
          '',
          '</div>',
        ]);
    })
    ->testAsync('null_child', async ()[defaults] ==> {
      expect(await render_to_strings_async(<div>{null}</div>))
        ->toEqual(vec[
          '<div>',
          '</div>',
        ]);
    })
    ->testAsync('frag_child', async ()[defaults] ==> {
      expect(await render_to_strings_async(
        <div>{<frag>{vec['one', <div id="two" />, null, 'four']}</frag>}</div>,
      ))
        ->toEqual(vec[
          '<div>',
          'one',
          '<div id="two">',
          '</div>',
          'four',
          '</div>',
        ]);
    })
    ->testAsync('dissolvable_element', async ()[defaults] ==> {
      expect(await render_to_strings_async(
        <div id="outer"><Dissolve><div id="child" /></Dissolve></div>,
      ))->toEqual(vec[
        '<div id="outer">',
        '<div class="dissolve">',
        '<div id="child">',
        '</div>',
        '</div>',
        '</div>',
      ]);
    })
    ->testAsync('simple_element', async ()[defaults] ==> {
      expect(await render_to_strings_async(
        <div id="outer"><Simple><div id="child" /></Simple></div>,
      ))->toEqual(vec[
        '<div id="outer">',
        '<div class="simple">',
        '<div id="child">',
        '</div>',
        '</div>',
        '</div>',
      ]);
    })
    ->testAsync('async_element', async ()[defaults] ==> {
      expect(await render_to_strings_async(
        <div id="outer"><Asynchronous><div id="child" /></Asynchronous></div>,
      ))->toEqual(vec[
        '<div id="outer">',
        '<div class="async">',
        '<div id="child">',
        '</div>',
        '</div>',
        '</div>',
      ]);
    })
    ->testAsync('successor_element', async ()[defaults] ==> {
      expect(await render_to_strings_async(
        <div id="outer"><Successor><div id="child" /></Successor></div>,
      ))->toEqual(vec[
        '<div id="outer">',
        '<div class="successor">',
        '<div id="child">',
        '</div>',
        '</div>',
        '</div>',
      ]);
    });
}
