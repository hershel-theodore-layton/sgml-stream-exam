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

  public function getAttribute(string $name)[]: ?string;
  public function getAttributes()[]: dict<string, string>;
  public function getChildren()[]: vec<Node>;
  public function getElementById(string $id)[]: ?Node;
  public function getElementsByClassname(string $classname)[]: vec<Node>;
  public function getName()[]: string;
  public function getNodeId()[]: int;
  public function getOuterHTML(Document $document)[]: string;
  public function getParent(Document $document)[]: Node;
  public function traverse()[]: Traversable<Node>;
  public function toUnitTestDump(Document $document)[]: this::UnitTestDump;
}
