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

  private dict<string, _Private\AttributeValue> $attributes = dict[];

  public function __construct(
    private NodeId $id,
    private NodeId $parentId,
    private string $tagName,
    dict<string, string> $attributes,
    private int $startByteRange,
    private int $endByteRange = -1,
  )[] {
    // Apply HTML attribute-name rules to the entire tree, including SVG.
    // Keep the first case-equivalent attribute.
    // See docs/quirks-and-oddities.md for this limit.
    foreach ($attributes as $name => $value) {
      $normalized_name = Str\lowercase($name);
      $this->attributes[$normalized_name] ??= new _Private\AttributeValue(
        $normalized_name === $name ? null : $name,
        $value,
      );
    }
  }

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
    return ($this->attributes[Str\lowercase($attr)] ?? null)?->getValue();
  }

  public function getAttributeNode(string $attr)[]: ?Attr {
    $normalized_name = Str\lowercase($attr);
    $value = $this->attributes[$normalized_name] ?? null;
    return $value is null
      ? null
      : new Attr($value->getName($normalized_name), $value->getValue());
  }

  public function getAttributeNames()[]: vec<string> {
    $names = vec[];
    foreach ($this->attributes as $name => $value) {
      $names[] = $value->getName($name);
    }
    return $names;
  }

  public function getAttributes()[]: dict<string, string> {
    $attributes = dict[];
    foreach ($this->attributes as $name => $value) {
      $attributes[$value->getName($name)] = $value->getValue();
    }
    return $attributes;
  }

  public function hasAttribute(string $attr)[]: bool {
    return C\contains_key($this->attributes, Str\lowercase($attr));
  }

  public function hasAttributes()[]: bool {
    return !C\is_empty($this->attributes);
  }

  public function getChildren(Document $doc)[]: vec<Node> {
    return $doc->getChildren($this->id);
  }

  public function hasChildNodes(Document $doc)[]: bool {
    return !C\is_empty($this->getChildren($doc));
  }

  public function contains(Node $other)[]: bool {
    return $this->startByteRange <= $other->startByteRange &&
      $this->endByteRange >= $other->endByteRange ||
      $this->tagName === Node::DOCTYPE;
  }

  public function getClassList()[]: keyset<string> {
    return Regex\split($this->getClassName(), re'/[ \t\n\r\f]+/')
      |> Keyset\filter($$, $c ==> $c !== '');
  }

  public function getClassName()[]: string {
    return $this->getAttribute('class') ?? '';
  }

  public function getChildElementCount(Document $doc)[]: int {
    return
      _Private\C\count_if($this->getChildren($doc), $c ==> $c->isElement());
  }

  public function getDataset()[]: dict<string, string> {
    if ($this->getNodeType() !== self::ELEMENT_NODE) {
      return dict[];
    }

    $dataset = dict[];
    foreach ($this->attributes as $attribute => $value) {
      if (!Str\starts_with($attribute, 'data-')) {
        continue;
      }

      $name = '';
      $length = Str\length($attribute);
      for ($i = 5; $i < $length; $i++) {
        $char = $attribute[$i];
        if (
          $char === '-' && $i + 1 < $length &&
          Str\contains('abcdefghijklmnopqrstuvwxyz', $attribute[$i + 1])
        ) {
          $i++;
          $name .= Str\uppercase($attribute[$i]);
        } else {
          $name .= $char;
        }
      }
      $dataset[$name] = $value->getValue();
    }
    return $dataset;
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
    $classes = Regex\split($class_name, re'/[ \t\n\r\f]+/')
      |> Keyset\filter($$, $c ==> $c !== '');
    if (C\is_empty($classes)) {
      return vec[];
    }

    $elements = vec[];
    foreach ($this->getDescendants($doc) as $descendant) {
      if ($descendant->getNodeType() !== self::ELEMENT_NODE) {
        continue;
      }

      // Avoid constructing the class list for obvious non-matches.
      $name = $descendant->getClassName();
      if (!C\every($classes, $class ==> Str\contains($name, $class))) {
        continue;
      }

      $class_list = $descendant->getClassList();
      if (C\every($classes, $class ==> C\contains($class_list, $class))) {
        $elements[] = $descendant;
      }
    }
    return $elements;
  }

  public function getElementsByTagName(
    Document $doc,
    string $tag_name,
  )[]: vec<Node> {
    $tag_name = Str\lowercase($tag_name);
    $elements = vec[];
    foreach ($this->getDescendants($doc) as $descendant) {
      if (
        $descendant->getNodeType() === self::ELEMENT_NODE &&
        ($tag_name === '*' ||
          Str\lowercase($descendant->getName()) === $tag_name)
      ) {
        $elements[] = $descendant;
      }
    }
    return $elements;
  }

  public function getFirstChild(Document $doc)[]: ?Node {
    return $this->getChildren($doc) |> C\first($$);
  }

  public function getFirstElementChild(Document $doc)[]: ?Node {
    foreach ($this->getChildren($doc) as $child) {
      if ($child->getNodeType() === self::ELEMENT_NODE) {
        return $child;
      }
    }
    return null;
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
    return $this->getAttribute('id') ?? '';
  }

  public function getInnerHTML(Document $doc)[]: string {
    return $this->getChildren($doc)
      |> Vec\map($$, $c ==> $c->getOuterHTML($doc))
      |> Str\join($$, '');
  }

  public function getNodeId()[]: NodeId {
    return $this->id;
  }

  public function getNodeValue(Document $doc)[]: ?string {
    if ($this->tagName === self::TXTNODE) {
      $source = $this->getOuterHTML($doc);
      switch ($this->getParent($doc)->getName()) {
        case 'script':
        case 'style':
        case 'xmp':
        case 'iframe':
        case 'noembed':
        case 'noframes':
        case 'plaintext':
          return $source;
        default:
          break;
      }

      // Decode ampersands last so escaped references are not decoded twice.
      // Str\replace_every_nonrecursive is not pure on supported HHVM 4 releases.
      return Str\replace($source, '&lt;', '<')
        |> Str\replace($$, '&gt;', '>')
        |> Str\replace($$, '&quot;', '"')
        |> Str\replace($$, '&#039;', "'")
        |> Str\replace($$, '&amp;', '&');
    }
    if ($this->tagName === self::COMMENT) {
      return Str\strip_prefix($this->getOuterHTML($doc), '<!--')
        |> Str\strip_suffix($$, '-->');
    }
    return null;
  }

  public function getTextContent(Document $doc)[]: string {
    if ($this->tagName === self::TXTNODE || $this->tagName === self::COMMENT) {
      return $this->getNodeValue($doc) ?? '';
    }

    $text = '';
    foreach ($this->getChildren($doc) as $child) {
      if ($child->getName() !== self::COMMENT) {
        $text .= $child->getTextContent($doc);
      }
    }
    return $text;
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

  public function getLastElementChild(Document $doc)[]: ?Node {
    $children = $this->getChildren($doc);
    for ($i = C\count($children) - 1; $i >= 0; $i--) {
      $child = $children[$i];
      if ($child->getNodeType() === self::ELEMENT_NODE) {
        return $child;
      }
    }
    return null;
  }

  public function getLastChildx(Document $doc)[]: Node {
    $last = $this->getLastChild($doc);
    invariant(
      $last is nonnull,
      'May not call getLastChildx on a Node with zero children.',
    );
    return $last;
  }

  public function getPreviousSibling(Document $doc)[]: ?Node {
    $siblings = $this->getSiblingsAndSelf($doc);
    foreach ($siblings as $i => $sibling) {
      if ($sibling->getNodeId() === $this->id) {
        return $siblings[$i - 1] ?? null;
      }
    }
    return null;
  }

  public function getNextSibling(Document $doc)[]: ?Node {
    $siblings = $this->getSiblingsAndSelf($doc);
    foreach ($siblings as $i => $sibling) {
      if ($sibling->getNodeId() === $this->id) {
        return $siblings[$i + 1] ?? null;
      }
    }
    return null;
  }

  public function getPreviousElementSibling(Document $doc)[]: ?Node {
    $previous = null;
    foreach ($this->getSiblingsAndSelf($doc) as $sibling) {
      if ($sibling->getNodeId() === $this->id) {
        return $previous;
      }
      if ($sibling->getNodeType() === self::ELEMENT_NODE) {
        $previous = $sibling;
      }
    }
    return null;
  }

  public function getNextElementSibling(Document $doc)[]: ?Node {
    $found_self = false;
    foreach ($this->getSiblingsAndSelf($doc) as $sibling) {
      if ($found_self && $sibling->getNodeType() === self::ELEMENT_NODE) {
        return $sibling;
      }
      if ($sibling->getNodeId() === $this->id) {
        $found_self = true;
      }
    }
    return null;
  }

  public function getSiblingsAndSelf(Document $doc)[]: vec<Node> {
    if ($this->getParent($doc)->getNodeId() === $this->id) {
      return vec[$this];
    }
    return $this->getParent($doc)->getChildren($doc);
  }

  public function getParent(Document $doc)[]: Node {
    return $doc->getByNodeIdx($this->parentId);
  }

  public function matches(Document $doc, string $selectors)[]: bool {
    return
      _Private\SelectorParser::parse($selectors)->matches($doc, $this, $this);
  }

  public function closest(Document $doc, string $selectors)[]: ?Node {
    $selector = _Private\SelectorParser::parse($selectors);
    $candidate = $this;
    while ($candidate->getNodeType() === self::ELEMENT_NODE) {
      if ($selector->matches($doc, $candidate, $this)) {
        return $candidate;
      }
      $candidate = $candidate->getParent($doc);
    }
    return null;
  }

  public function querySelector(Document $doc, string $selectors)[]: ?Node {
    $selector = _Private\SelectorParser::parse($selectors);
    foreach ($this->getDescendants($doc) as $descendant) {
      // This is very inefficient, as we evaluate every node once,
      // instead of doing something smarter. If this shows up in your
      // CPU profile for your tests, a lot of improvement can be made.
      if ($selector->matches($doc, $descendant, $this)) {
        return $descendant;
      }
    }
    return null;
  }

  public function querySelectorAll(
    Document $doc,
    string $selectors,
  )[]: vec<Node> {
    $selector = _Private\SelectorParser::parse($selectors);
    return Vec\filter(
      $this->getDescendants($doc),
      $descendant ==> $selector->matches($doc, $descendant, $this),
    );
  }

  public function isEqualNode(
    Document $doc,
    ?Node $other,
    ?Document $other_doc = null,
  )[]: bool {
    invariant($doc->owns($this), 'The document must own this node.');
    if ($other is null) {
      return false;
    }

    $other_doc ??= $doc;
    invariant(
      $other_doc->owns($other),
      'The other document must own the other node.',
    );
    if ($this->tagName !== $other->tagName) {
      return false;
    }

    if (C\count($this->attributes) !== C\count($other->attributes)) {
      return false;
    }
    foreach ($this->attributes as $name => $value) {
      $other_value = $other->attributes[$name] ?? null;
      if (
        $other_value is null ||
        $other_value->getValue() !== $value->getValue()
      ) {
        return false;
      }
    }
    if ($this->getNodeValue($doc) !== $other->getNodeValue($other_doc)) {
      return false;
    }

    $children = $this->getChildren($doc);
    $other_children = $other->getChildren($other_doc);
    if (C\count($children) !== C\count($other_children)) {
      return false;
    }
    foreach ($children as $i => $child) {
      if (!$child->isEqualNode($doc, $other_children[$i], $other_doc)) {
        return false;
      }
    }
    return true;
  }

  public function isElement()[]: bool {
    return
      $this->tagName !== static::COMMENT && $this->tagName !== static::TXTNODE;
  }

  public function setEndByteRange(int $end_byte_range)[write_props]: void {
    $this->endByteRange = $end_byte_range;
  }
}
