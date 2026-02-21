/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam;

interface Node {
  const type UnitTestDump = shape(
    'outerHTML' => string,
    'name' => string,
    'attributes' => dict<string, string>,
    'children' => vec<mixed>,
    /*_*/
  );

  public function getAttributes()[]: dict<string, string>;
  public function getChildren()[]: vec<Node>;
  public function getName()[]: string;
  public function getOuterHTML(Document $document)[]: string;
  public function toUnitTestDump(Document $document)[]: this::UnitTestDump;
}
