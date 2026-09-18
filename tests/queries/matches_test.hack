/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HH\Lib\{Dict, Vec};
use namespace HTL\{SGMLStreamExam, TestChain};
use function HTL\Expect\{expect, expect_invoked};

<<TestChain\Discover>>
function matches_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith2ParamsAsync(
      'matches supported selectors',
      async () ==> Dict\map_with_key(
        matches_cases(),
        ($selector, $ids) ==> tuple($selector, $ids),
      ),
      async ($selector, $expected_ids)[defaults] ==> {
        $doc = await matches_document_async();
        $nodes = $doc->getCurrentNode()->getDescendants($doc);
        $hits = Vec\filter($nodes, $n ==> $n->matches($doc, $selector));
        expect(Vec\map($hits, $n ==> $n->getId()))->toEqual($expected_ids);
      },
    )
    ->testAsync(
      'rejects invalid and unsupported selectors',
      async ()[defaults] ==> {
        $doc = await matches_document_async();
        $node = $doc->getCurrentNode()->getElementByIdx($doc, 'first');
        foreach (
          vec[
            '',
            ' ',
            ',',
            'div,',
            ',div',
            'div,,span',
            'div >',
            '> div',
            'div + ~ span',
            'div..item',
            '#',
            '.123',
            '#123',
            'div*',
            '#/**/first',
            ':not/**/(.hot)',
            ':nth-child(2/**/n)',
            ':nth-child(1/**/2)',
            'div|span',
            '*|span',
            '[ns|attr]',
            '[*|attr]',
            '[attr!=x]',
            '[',
            '[]',
            '[data-code=]',
            '[data-code=123]',
            '[data-code="x" q]',
            '[data-code i]',
            '[data-code="x"',
            '[data-code~ =x]',
            'span::before',
            'span:before',
            ':hover',
            ':focus',
            ':checked',
            ':has(span)',
            ':lang(en)',
            ':unknown',
            ':first-child()',
            ':not()',
            ':not(.item, :unknown)',
            ':not(.item,)',
            ':is(.item',
            ':nth-child()',
            ':nth-child(2n +)',
            ':nth-child(2 n)',
            ':nth-child(\\32)',
            ':nth-child(\\32 n)',
            ':nth-child(\\2b n)',
            ':nth-child(n 1)',
            ':nth-child(1.5)',
            ':nth-child("2n")',
            ':nth-child(2 of .item)',
            ':nth-child(99999999999999999999999)',
            'span, [',
            '*,:unknown',
            'div/*',
            "[title=\"line\nbreak\"]",
            ".bad\\\n",
            '.bad\\',
          ] as $selector
        ) {
          expect_invoked(() ==> $node->matches($doc, $selector))
            ->toHaveThrown<SGMLStreamExam\InvalidSelectorException>();
          // Non-elements still validate the entire selector.
          expect_invoked(
            () ==> $doc->getCurrentNode()->matches($doc, $selector),
          )
            ->toHaveThrown<SGMLStreamExam\InvalidSelectorException>();
        }
      },
    )
    ->testAsync(
      'HTML attribute case rules and explicit flags',
      async ()[defaults] ==> {
        $doc = new SGMLStreamExam\Document();
        $doc->addNode(shape(
          'tag_name' => 'INPUT',
          'attributes' => dict['TYPE' => 'TeXT', 'data-value' => 'TeXT'],
          'text' => '<INPUT TYPE="TeXT" data-value="TeXT">',
        ));
        $node = $doc->getCurrentNode();
        $doc->closeNode();
        $doc->freeze();

        expect($node->matches($doc, 'input[type=text]'))->toBeTrue();
        expect($node->matches($doc, '[TYPE=TEXT]'))->toBeTrue();
        expect($node->matches($doc, '[type=text s]'))->toBeFalse();
        expect($node->matches($doc, '[type=TeXT s]'))->toBeTrue();
        expect($node->matches($doc, '[data-value=text]'))->toBeFalse();
        expect($node->matches($doc, '[data-value=text i]'))->toBeTrue();
      },
    )
    ->testAsync('limits nested selectors', async ()[defaults] ==> {
      $doc = await matches_document_async();
      $node = $doc->getCurrentNode()->getElementByIdx($doc, 'first');
      $selector = '*';
      for ($i = 0; $i < 66; $i++) {
        $selector = ':not('.$selector.')';
      }
      expect_invoked(() ==> $node->matches($doc, $selector))
        ->toHaveThrown<SGMLStreamExam\InvalidSelectorException>('nesting');
    })
    ->testAsync('doctype does not match', async ()[defaults] ==> {
      $doc = await matches_document_async();
      expect($doc->getCurrentNode()->matches($doc, '*'))->toBeFalse();
    })
    ->testAsync(
      'backtracks over ancestors and preceding siblings',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <article>
              <div><div><span id="deep" /></div></div>
            </article>
            <div id="siblings">
              <input />
              <div />
              <div />
              <span id="last" />
            </div>
          </doctype>,
        );
        $root = $doc->getCurrentNode();
        expect(
          $root->getElementByIdx($doc, 'deep')
            ->matches($doc, 'article > div span'),
        )
          ->toBeTrue();
        expect(
          $root->getElementByIdx($doc, 'last')
            ->matches($doc, 'input + div ~ span'),
        )
          ->toBeTrue();
      },
    );
}

async function matches_document_async(
)[defaults]: Awaitable<SGMLStreamExam\Document> {
  return await render_to_document_async(
    <doctype>
      <div id="root" class="panel">
        <span id="first" class="item hot" data-code="AbC-xy" data-empty="" />
        Text
        <conditional_comment if="IE">Comment</conditional_comment>
        <input id="input" />
        <span id="second" class="item" data-code="abc" />
        <div id="group" class="item" data-words={"one\ttwo\nthree"}>
          <span id="nested" class="item hot" />
        </div>
        <span id="last" class="item" />
        <div id="comment">
          <conditional_comment if="IE">Comment</conditional_comment>
        </div>
        <div id="space">{' '}</div>
        <span
          id="123:é"
          class="a.b --custom 😀 �"
          data-special={'a,b] > ("x")'}
          data-unicode="É"
          data-lang="en-US"
        />
      </div>
    </doctype>,
  );
}

function matches_cases()[]: dict<string, vec<string>> {
  return dict[
    '*' => vec[
      'root',
      'first',
      'input',
      'second',
      'group',
      'nested',
      'last',
      'comment',
      'space',
      '123:é',
    ],
    'SPAN' => vec['first', 'second', 'nested', 'last', '123:é'],
    'span.item.hot' => vec['first', 'nested'],
    'span.item.item' => vec['first', 'second', 'nested', 'last'],
    '#first' => vec['first'],
    '#FIRST' => vec[],
    '.HOT' => vec[],
    '.it' => vec[],
    '#first#second' => vec[],
    'input, #first, input' => vec['first', 'input'],
    " \tinput\r\n, #first\f " => vec['first', 'input'],
    'div > span.hot' => vec['first', 'nested'],
    '#root > .hot' => vec['first'],
    '#root .hot' => vec['first', 'nested'],
    'input + span' => vec['second'],
    '#first + input' => vec['input'],
    '#first + span' => vec[],
    'input ~ span.item' => vec['second', 'last'],
    '#root > input ~ div > span' => vec['nested'],
    '#first/*comment*/.hot' => vec['first'],
    './**/hot' => vec['first', 'nested'],
    "#root/*x*/ \t/*y*/span.hot" => vec['first', 'nested'],
    '[data-code]' => vec['first', 'second'],
    '[DATA-CODE]' => vec['first', 'second'],
    '[missing]' => vec[],
    '[data-empty=""]' => vec['first'],
    '[missing=""]' => vec[],
    '[data-code="AbC-xy"]' => vec['first'],
    "[data-code='AbC-xy']" => vec['first'],
    '[data-code=abc]' => vec['second'],
    '[data-code=ABC]' => vec[],
    '[data-code=ABC i]' => vec['second'],
    '[data-code=ABC I]' => vec['second'],
    '[data-code=ABC s]' => vec[],
    '[data-code^=Ab]' => vec['first'],
    '[data-code$=xy]' => vec['first'],
    '[data-code*=C-]' => vec['first'],
    '[data-code|=AbC]' => vec['first'],
    '[data-code|=abc]' => vec['second'],
    '[data-words~=two]' => vec['group'],
    '[data-words~="one two"]' => vec[],
    '[data-empty~=""]' => vec[],
    '[data-code^=""]' => vec[],
    '[data-code$=""]' => vec[],
    '[data-code*=""]' => vec[],
    '[data-unicode="é" i]' => vec[],
    '[data-lang|=en]' => vec['123:é'],
    '[data-special="a,b] > (\\"x\\")"]' => vec['123:é'],
    '#\\31 23\\:é' => vec['123:é'],
    '#\\00003123\\:é' => vec['123:é'],
    '.a\\.b' => vec['123:é'],
    '.--custom' => vec['123:é'],
    '.😀' => vec['123:é'],
    '.\\1f600' => vec['123:é'],
    '.\\d800' => vec['123:é'],
    '.\\110000' => vec['123:é'],
    '.\\0' => vec['123:é'],
    '[data-unicode="\\c9"]' => vec['123:é'],
    "[data-code=\"AbC-\\\nxy\"]" => vec['first'],
    ':scope#first' => vec['first'],
    '#root :scope.hot' => vec['first', 'nested'],
    ':scope > span' => vec[],
    ':root' => vec['root'],
    ':empty' =>
      vec['first', 'input', 'second', 'nested', 'last', 'comment', '123:é'],
    ':first-child' => vec['root', 'first', 'nested'],
    ':last-child' => vec['root', 'nested', '123:é'],
    ':only-child' => vec['root', 'nested'],
    'span:first-of-type' => vec['first', 'nested'],
    'span:last-of-type' => vec['nested', '123:é'],
    'span:only-of-type' => vec['nested'],
    'input:only-of-type' => vec['input'],
    '#root > :nth-child(2)' => vec['input'],
    '#root > :nth-child(odd)' => vec['first', 'second', 'last', 'space'],
    '#root > :nth-child(even)' => vec['input', 'group', 'comment', '123:é'],
    '#root > :nth-child(2n/**/+1)' => vec['first', 'second', 'last', 'space'],
    '#root > :nth-child(n/**/-1)' => vec[
      'first',
      'input',
      'second',
      'group',
      'last',
      'comment',
      'space',
      '123:é',
    ],
    '#root > :nth-child(2n + 1)' => vec['first', 'second', 'last', 'space'],
    '#root > :nth-child(-n+3)' => vec['first', 'input', 'second'],
    '#root > :nth-child(n-6)' => vec[
      'first',
      'input',
      'second',
      'group',
      'last',
      'comment',
      'space',
      '123:é',
    ],
    '#root > :nth-child(+n + 6)' => vec['comment', 'space', '123:é'],
    '#root > :nth-child(0n+2)' => vec['input'],
    '#root > :nth-child(0)' => vec[],
    '#root > :nth-child(-2)' => vec[],
    '#root > :nth-last-child(2)' => vec['space'],
    '#root > span:nth-of-type(2)' => vec['second'],
    '#root > span:nth-last-of-type(2)' => vec['last'],
    'span:not(.hot)' => vec['second', 'last', '123:é'],
    'span:not(.hot, #last)' => vec['second', '123:é'],
    'span:not(#root > span)' => vec['nested'],
    'span:is(.hot, #last)' => vec['first', 'nested', 'last'],
    'span:where(.hot, #last)' => vec['first', 'nested', 'last'],
    'span:not(:is(.hot, #last))' => vec['second', '123:é'],
    ':is(#first, :unknown)' => vec['first'],
    ':where(:unknown, #first)' => vec['first'],
    ':is(, #first,)' => vec['first'],
    ':is()' => vec[],
    ':where(:unknown)' => vec[],
    ':not(:is())#first' => vec['first'],
    ':is(#root > .hot, #group > .hot)' => vec['first', 'nested'],
  ];
}
