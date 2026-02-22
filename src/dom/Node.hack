/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam;

interface Node {
  const string COMMENT_NAME = '!COMMENT';
  const string DOCTYPE_NAME = '!DOCTYPE';
  const string TXTNODE_NAME = '!TXTNODE';

  const type UnitTestDump = shape(
    'outerHTML' => string,
    'name' => string,
    'attributes' => dict<string, string>,
    'children' => vec<mixed>,
    /*_*/
  );

  public function getAttribute(string $name)[]: ?string;
  public function getAttributes()[]: dict<string, string>;
  public function getChildElementCount()[]: int;
  public function getChildren()[]: vec<Node>;
  public function getClassList()[]: keyset<string>;
  public function getClassName()[]: string;
  public function getElementById(string $id)[]: ?Node;
  public function getElementByIdx(string $id)[]: Node;
  public function getElementsByClassName(string $class_name)[]: vec<Node>;
  public function getFirstChild()[]: ?Node;
  public function getFirstChildx()[]: Node;
  public function getLastChild()[]: ?Node;
  public function getLastChildx()[]: Node;
  public function getId()[]: string;
  public function getInnerHTML(Document $document)[]: string;
  public function getName()[]: string;
  public function getNextSibling(Document $document)[]: ?Node;
  public function getNodeId()[]: int;
  public function getOuterHTML(Document $document)[]: string;
  public function getParent(Document $document)[]: Node;
  public function getPreviousSibling(Document $document)[]: ?Node;
  public function getSiblingsAndSelf(Document $document)[]: vec<Node>;
  public function isElement()[]: bool;
  public function traverse()[]: Traversable<Node>;
  public function toUnitTestDump(Document $document)[]: this::UnitTestDump;
}
