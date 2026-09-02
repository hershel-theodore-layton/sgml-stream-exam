/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam;

use namespace HH\Lib\{C, Keyset, Regex, Str, Vec};

final class Node {
  const string COMMENT = '!COMMENT';
  const string DOCTYPE = '!DOCTYPE';
  const string TXTNODE = '!TXTNODE';
  const int ELEMENT_NODE = 1;
  const int TEXT_NODE = 3;
  const int COMMENT_NODE = 8;
  const int DOCUMENT_TYPE_NODE = 10;

  public function __construct(
    private NodeId $id,
    private NodeId $parentId,
    private string $tagName,
    private dict<string, string> $attributes,
    private int $startByteRange,
    private int $endByteRange = -1,
  )[] {}

  public function getAncestors(Document $doc)[]: vec<Node> {
    $ancestors = vec[];
    $self = $this;

    do {
      $self = $self->getParent($doc);
      $ancestors[] = $self;
    } while ($self->getName() !== Node::DOCTYPE);

    return $ancestors;
  }

  public function getAttribute(string $attr)[]: ?string {
    return $this->attributes[$attr] ?? null;
  }

  public function getAttributes()[]: dict<string, string> {
    return $this->attributes;
  }

  public function getChildren(Document $doc)[]: vec<Node> {
    return $doc->getChildren($this->id);
  }

  public function getClassList()[]: keyset<string> {
    return Regex\split($this->getClassName(), re'/\s+/')
      |> Keyset\filter($$, $c ==> $c !== '');
  }

  public function getClassName()[]: string {
    return $this->attributes['class'] ?? '';
  }

  public function getChildElementCount(Document $doc)[]: int {
    return
      _Private\C\count_if($this->getChildren($doc), $c ==> $c->isElement());
  }

  public function getDescendants(Document $doc)[]: vec<Node> {
    return $doc->getDescendants($this->id);
  }

  public function getDescendantsAndSelf(Document $doc)[]: vec<Node> {
    return $doc->getDescendantsAndSelf($this->id);
  }

  public function getElementById(Document $doc, string $id)[]: ?Node {
    // Special case, `<div></div>`'s id is `""`, but getElementById("") should
    // not return this element.
    if ($id === '') {
      return null;
    }

    foreach ($this->getDescendants($doc) as $desc) {
      if ($desc->getId() === $id) {
        return $desc;
      }
    }

    return null;
  }

  public function getElementByIdx(Document $doc, string $id)[]: Node {
    $ret = $this->getElementById($doc, $id);
    invariant($ret is nonnull, 'Element with the id "%s" was not found.', $id);
    return $ret;
  }

  public function getElementsByClassName(
    Document $doc,
    string $class_name,
  )[]: vec<Node> {
    // Special case, `<div></div>`'s class is `""`, but getElementsByClassName("")
    // should not return this element.
    if ($class_name === '') {
      return vec[];
    }

    $elements = vec[];
    foreach ($this->getDescendants($doc) as $descendant) {
      if (
        // This method is rather commonly called in tests,
        // so checking for the string-contains is a quick "skip this".
        // Constructing the classList is rather expensive, so avoid if possible.
        Str\contains($descendant->getClassName(), $class_name) &&
        C\contains($descendant->getClassList(), $class_name)
      ) {
        $elements[] = $descendant;
      }
    }
    return $elements;
  }

  public function getFirstChild(Document $doc)[]: ?Node {
    return $this->getChildren($doc) |> C\first($$);
  }

  public function getFirstChildx(Document $doc)[]: Node {
    $first = $this->getFirstChild($doc);
    invariant(
      $first is nonnull,
      'May not call getFirstChildx on a Node with zero children.',
    );
    return $first;
  }

  public function getId()[]: string {
    return $this->attributes['id'] ?? '';
  }

  public function getInnerHTML(Document $doc)[]: string {
    return $this->getChildren($doc)
      |> Vec\map($$, $c ==> $c->getOuterHTML($doc))
      |> Str\join($$, '');
  }

  public function getNodeId()[]: NodeId {
    return $this->id;
  }

  public function getName()[]: string {
    return $this->tagName;
  }

  public function getNodeType()[]: int {
    switch ($this->tagName) {
      case self::TXTNODE:
        return self::TEXT_NODE;
      case self::COMMENT:
        return self::COMMENT_NODE;
      case self::DOCTYPE:
        return self::DOCUMENT_TYPE_NODE;
      default:
        return self::ELEMENT_NODE;
    }
  }

  public function getOuterHTML(Document $doc)[]: string {
    return $doc->sliceBytes($this->startByteRange, $this->endByteRange);
  }

  public function getLastChild(Document $doc)[]: ?Node {
    return $this->getChildren($doc) |> C\last($$);
  }

  public function getLastChildx(Document $doc)[]: Node {
    $last = $this->getLastChild($doc);
    invariant(
      $last is nonnull,
      'May not call getLastChildx on a Node with zero children.',
    );
    return $last;
  }

  public function getParent(Document $doc)[]: Node {
    return $doc->getByNodeIdx($this->parentId);
  }

  public function isElement()[]: bool {
    return
      $this->tagName !== static::COMMENT && $this->tagName !== static::TXTNODE;
  }

  public function setEndByteRange(int $end_byte_range)[write_props]: void {
    $this->endByteRange = $end_byte_range;
  }
}
