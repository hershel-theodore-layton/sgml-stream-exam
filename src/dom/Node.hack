/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam;

use namespace HH\Lib\{Keyset, Regex, Str, Vec};

final class Node {
  const string COMMENT = '!COMMENT';
  const string DOCTYPE = '!DOCTYPE';
  const string TXTNODE = '!TXTNODE';

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
      $self = $self->getParentx($doc);
      $ancestors[] = $self;
    } while ($self->getTagName() !== Node::DOCTYPE);

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

  public function getElementById(Document $doc, string $id)[]: ?Node {
    // Special case, `<div></div>`'s id is `""`, but getElementById("") should
    // not return this element. 
    if ($id === '') {
      return null;
    }

    foreach ($doc->getDescendants($this->id) as $desc) {
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

  public function getTagName()[]: string {
    return $this->tagName;
  }

  public function getOuterHTML(Document $doc)[]: string {
    return $doc->sliceBytes($this->startByteRange, $this->endByteRange);
  }

  public function getParentx(Document $doc)[]: Node {
    return $doc->getByNodeIdx($this->parentId);
  }

  public function setEndByteRange(int $end_byte_range)[write_props]: void {
    $this->endByteRange = $end_byte_range;
  }
}
