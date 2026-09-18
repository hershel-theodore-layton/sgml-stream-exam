/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HTL\{SGMLStreamExam, TestChain};
use type HH\InvariantException;
use function HTL\Expect\{expect, expect_invoked};
use function HTL\Pragma\pragma;

<<TestChain\Discover>>
function is_equal_node_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testAsync('HTML attribute name casing does not affect equality', async ()[defaults] ==> {
      $doc = await render_to_document_async(
        <doctype>
          <div data-userId="123"></div>
          <div data-userid="123"></div>
        </doctype>,
      );
      $nodes = $doc->getCurrentNode()->getChildren($doc);
      $left = $nodes[0];
      $right = $nodes[1];
      expect($left->getDataset())->toEqual($right->getDataset());
      expect($left->isEqualNode($doc, $right))->toBeTrue();
      expect($right->isEqualNode($doc, $left))->toBeTrue();
    })
    ->testWith3ParamsAsync(
      'isEqualNode across documents',
      async () ==> dict[
        'empty_roots' => tuple(vec[], vec[], true),
        'equal_nested_trees' => tuple(
          vec['<div>', '<span>', 'hello', '</span>', '<!--note-->', '</div>'],
          vec['<div>', '<span>', 'hello', '</span>', '<!--note-->', '</div>'],
          true,
        ),
        'attribute_order' => tuple(
          vec['<div id="a" class="b">', '</div>'],
          vec['<div class="b" id="a">', '</div>'],
          true,
        ),
        'attribute_value' => tuple(
          vec['<div id="a">', '</div>'],
          vec['<div id="b">', '</div>'],
          false,
        ),
        'attribute_name' => tuple(
          vec['<div id="">', '</div>'],
          vec['<div class="">', '</div>'],
          false,
        ),
        'missing_empty_attribute' =>
          tuple(vec['<div id="">', '</div>'], vec['<div>', '</div>'], false),
        'strict_attribute_values' => tuple(
          vec['<div data-value="0">', '</div>'],
          vec['<div data-value="00">', '</div>'],
          false,
        ),
        'different_tags' =>
          tuple(vec['<div>', '</div>'], vec['<span>', '</span>'], false),
        'case_sensitive_names' =>
          tuple(vec['<div>', '</div>'], vec['<DIV>', '</DIV>'], false),
        'equal_text' => tuple(vec['hello'], vec['hello'], true),
        'different_text' => tuple(vec['hello'], vec['world'], false),
        'text_whitespace' => tuple(vec['hello'], vec[' hello'], false),
        'equal_comments' => tuple(vec['<!--a-->'], vec['<!--a-->'], true),
        'different_comments' => tuple(vec['<!--a-->'], vec['<!--b-->'], false),
        'different_node_types' => tuple(vec['a'], vec['<!--a-->'], false),
        'child_count' => tuple(
          vec['<div>', '</div>'],
          vec['<div>', '<span>', '</span>', '</div>'],
          false,
        ),
        'child_order' => tuple(
          vec['<div>', '<span>', '</span>', '<input>', '</div>'],
          vec['<div>', '<input>', '<span>', '</span>', '</div>'],
          false,
        ),
        'nested_difference' => tuple(
          vec['<div>', '<span>', 'a', '</span>', '</div>'],
          vec['<div>', '<span>', 'b', '</span>', '</div>'],
          false,
        ),
        'text_chunk_boundaries_do_not_affect_equality' => tuple(
          vec['<div>', 'ab', '</div>'],
          vec['<div>', 'a', 'b', '</div>'],
          true,
        ),
      ],
      async ($left_chunks, $right_chunks, $expected)[defaults] ==> {
        $left_consumer = new SGMLStreamExam\ToHTMLDocumentConsumer();
        $right_consumer = new SGMLStreamExam\ToHTMLDocumentConsumer();
        await $left_consumer->consumeAsync('<!DOCTYPE html>');
        await $right_consumer->consumeAsync('<!DOCTYPE html>');
        foreach ($left_chunks as $chunk) {
          // The parser must consume chunks sequentially.
          pragma('PhaLinters', 'fixme:dont_await_in_a_loop');
          await $left_consumer->consumeAsync($chunk);
        }
        foreach ($right_chunks as $chunk) {
          // The parser must consume chunks sequentially.
          pragma('PhaLinters', 'fixme:dont_await_in_a_loop');
          await $right_consumer->consumeAsync($chunk);
        }
        await $left_consumer->theDocumentIsCompleteAsync();
        await $right_consumer->theDocumentIsCompleteAsync();
        $left_doc = $left_consumer->toDocument();
        $right_doc = $right_consumer->toDocument();
        $left = $left_doc->getCurrentNode();
        $right = $right_doc->getCurrentNode();

        expect($left->isEqualNode($left_doc, $right, $right_doc))
          ->toEqual($expected);
        expect($right->isEqualNode($right_doc, $left, $left_doc))
          ->toEqual($expected);
        expect($left->isEqualNode($left_doc, $left))->toBeTrue();
        expect($left->isEqualNode($left_doc, null))->toBeFalse();
      },
    )
    ->testAsync('rejects mismatched documents', async ()[defaults] ==> {
      $doc = await render_to_document_async(<doctype><div /></doctype>);
      $other_doc = await render_to_document_async(<doctype><span /></doctype>);
      $node = $doc->getCurrentNode()->getFirstChildx($doc);
      $other = $other_doc->getCurrentNode()->getFirstChildx($other_doc);

      // IDs collide across documents; ownership requires object identity.
      expect($node->getNodeId())->toEqual($other->getNodeId());
      expect($doc->owns($node))->toBeTrue();
      expect($doc->owns($doc->getCurrentNode()))->toBeTrue();
      expect($doc->owns($other))->toBeFalse();
      expect($doc->owns(clone $node))->toBeFalse();
      expect((new SGMLStreamExam\Document())->owns($node))->toBeFalse();

      expect_invoked(() ==> $node->isEqualNode($other_doc, $other))
        ->toHaveThrown<InvariantException>('The document must own this node.');
      expect_invoked(() ==> $node->isEqualNode($other_doc, null))
        ->toHaveThrown<InvariantException>('The document must own this node.');
      expect_invoked(() ==> $node->isEqualNode($doc, $other))
        ->toHaveThrown<InvariantException>(
          'The other document must own the other node.',
        );
      expect_invoked(() ==> $node->isEqualNode($doc, $other, $doc))
        ->toHaveThrown<InvariantException>(
          'The other document must own the other node.',
        );
      expect($node->isEqualNode($doc, $other, $other_doc))->toBeFalse();
      expect($node->isEqualNode($doc, null))->toBeFalse();
    })
    ->testAsync(
      'ignores node identity, parents, and byte positions',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="left"><span class="x">same</span></div>
            <div id="right"><input /><span class="x">same</span></div>
          </doctype>,
        );
        $root = $doc->getCurrentNode();
        $left = $root->getElementByIdx($doc, 'left')->getFirstChildx($doc);
        $right = $root->getElementByIdx($doc, 'right')->getLastChildx($doc);

        expect($left === $right)->toBeFalse();
        expect($left->isEqualNode($doc, $right))->toBeTrue();
        expect($right->isEqualNode($doc, $left))->toBeTrue();
        expect($root->isEqualNode($doc, $left))->toBeFalse();
      },
    );
}
