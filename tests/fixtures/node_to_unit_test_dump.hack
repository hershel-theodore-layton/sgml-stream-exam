/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HH\Lib\Vec;
use namespace HTL\SGMLStreamExam;

function node_to_unit_test_dump(
  SGMLStreamExam\Document $doc,
  SGMLStreamExam\Node $node,
)[]: dict<string, mixed> {
  return dict[
    'outerHTML' => $node->getOuterHTML($doc),
    'name' => $node->getName(),
    'attributes' => $node->getAttributes(),
    'children' => Vec\map(
      $node->getChildren($doc),
      $child ==> node_to_unit_test_dump($doc, $child),
    ),
  ];
}
