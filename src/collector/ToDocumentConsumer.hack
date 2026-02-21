/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam;

use namespace HH\Lib\{C, Str};
use namespace HTL\SGMLStreamInterfaces;

/**
 * This consumer parses the HTML that is being fed to it. It depends on
 * receiving its input piecewise. This is intended to be used in combination
 * with `PiecewiseStream`. It expects input to be in the format of html-stream
 * and does not parse general HTML. Results may be dissapointing if you depend
 * on ToSGMLStringAsync to inject valid HTML in otherwise html-stream trees.
 */
final class ToHTMLDocumentConsumer implements SGMLStreamInterfaces\Consumer {
  /**
   * @see https://developer.mozilla.org/en-US/docs/Glossary/Void_element
   */
  const keyset<string> STANDARD_VOID_ELEMENTS = keyset[
    'area',
    'base',
    'br',
    'col',
    'embed',
    'hr',
    'img',
    'input',
    'link',
    'meta',
    'param',
    'source',
    'track',
    'wbr',
  ];

  const string DOCTYPE = '<!DOCTYPE html>';

  private _Private\Stack<_Private\Node> $openElements;
  private bool $isComplete = false;
  private _Private\Node $rootNode;
  private string $documentText = '';
  private _Private\ParserState $parserState = _Private\ParserState::DATA_STATE;
  private int $nodeId = 1;

  public function __construct(
    private keyset<string> $void_elements = static::STANDARD_VOID_ELEMENTS,
  )[write_props] {
    $root_node = new _Private\Node(
      0, // Start index
      Str\length(static::DOCTYPE), // End index
      _Private\Node::DOCTYPE_NAME,
      dict[],
      0, // Node id
      0, // Parent node id
    );

    $this->openElements = new _Private\Stack(vec[$root_node]);
    $this->rootNode = $root_node;
  }

  public async function consumeAsync(string $bytes)[defaults]: Awaitable<void> {
    if ($this->documentText === '') {
      if ($bytes !== '<!DOCTYPE html>') {
        throw new NotAnHTML5DocumentException(
          Str\format(
            'This consumer excepts HTML5 documents, which start with %s, got: %s',
            static::DOCTYPE,
            $bytes,
          ).
          $bytes,
        );
      }

      // We exit early, because the constructor already created this document.
      $this->documentText .= $bytes;
      return;
    }

    switch ($this->parserState) {
      case _Private\ParserState::DATA_STATE:
        // Comments are not implemented by html-stream.
        // Users may have implemented them like so '<!-- text -->'
        // or like so '<!--', ' text ', '-->'.
        // Let's treat '<!-- text -->' as '<!-- text ', '-->',
        // so the code only handles non-closing comment tags.
        if (Str\starts_with($bytes, '<!--')) {
          $start_comment = Str\strip_suffix($bytes, '-->');
          $this->parseHtml($start_comment);
          if ($start_comment !== $bytes) {
            $this->parseHtml('-->');
          }

          return;
        }

        $this->parseHtml($bytes);
        return;

      case _Private\ParserState::COMMENT_STATE:
        $this->parseHtml($bytes);
        return;
    }
  }

  public async function receiveWaitNotificationAsync(
  )[defaults]: Awaitable<void> {}
  public async function flushAsync()[defaults]: Awaitable<void> {}
  public async function theDocumentIsCompleteAsync(
  )[defaults]: Awaitable<void> {
    $this->isComplete = true;
  }

  public function toDocument()[]: Document {
    return new Document($this->rootNode, $this->documentText);
  }

  private function getTextIndex()[]: int {
    return Str\length($this->documentText);
  }

  private function pushOpenElement(
    _Private\Node $node,
    string $bytes,
  )[write_props]: void {
    $this->documentText .= $bytes;
    $parent = $this->openElements->peek();

    $node->setNodeId($this->nodeId);
    $this->nodeId++;

    $node->setParentNodeId($parent->getNodeId());
    $parent->append($node);
    $this->openElements->push($node);
  }

  private function popOpenElement()[write_props]: void {
    $this->openElements->pop()->setEndIndex($this->getTextIndex());
  }

  private function parseHtml(string $bytes)[defaults]: void {
    switch ($this->parserState) {
      case _Private\ParserState::DATA_STATE:
        if (Str\starts_with($bytes, '<!--')) {
          $comment = _Private\Node::createComment($this->getTextIndex());
          $this->pushOpenElement($comment, $bytes);
          $this->parserState = _Private\ParserState::COMMENT_STATE;
          return;
        }

        if (
          Str\starts_with($bytes, '</') &&
          Str\search_last($bytes, '<') === 0 &&
          Str\ends_with($bytes, '>') &&
          Str\search($bytes, '>') === Str\length($bytes) - 1
        ) {
          $this->parseClosingTag($bytes);
          return;
        }

        if (
          Str\starts_with($bytes, '<') &&
          Str\search_last($bytes, '<') === 0 &&
          Str\ends_with($bytes, '>') &&
          Str\search($bytes, '>') === Str\length($bytes) - 1
        ) {
          $this->parseOpeningTag($bytes);
          return;
        }

        $node = _Private\Node::createTextNode($this->getTextIndex());
        $this->pushOpenElement($node, $bytes);
        $this->popOpenElement();
        return;

      case _Private\ParserState::COMMENT_STATE:
        $this->documentText .= $bytes;
        if (Str\ends_with($bytes, '-->')) {
          $this->popOpenElement();
        }
        return;
    }
  }

  private function parseOpeningTag(string $bytes)[defaults]: void {
    $rest = Str\strip_prefix($bytes, '<') |> Str\strip_suffix($$, '>');

    list($tag_name, $rest) = _Private\consume_until_space_exclusive($rest);
    $attributes = dict[];

    do {
      list($attribute_name, $end_char, $rest) =
        _Private\consume_until_equals_or_space_inclusive($rest);

      if ($end_char === '=') {
        list($value, $rest) = _Private\consume_attribute_value($rest);
        $attributes[$attribute_name] = $value;
      } else if ($end_char === ' ') {
        $attributes[$attribute_name] = '';
      }
    } while ($rest !== '');

    $node = _Private\Node::createElement(
      $this->getTextIndex(),
      $tag_name,
      $attributes,
    );
    $this->pushOpenElement($node, $bytes);

    if (C\contains_key($this->void_elements, $tag_name)) {
      $this->popOpenElement();
    }
  }

  private function parseClosingTag(string $bytes)[write_props]: void {
    $expected_tag = '</'.$this->openElements->peek()->getName().'>';

    if ($bytes !== $expected_tag) {
      throw new UnexpectedHTMLException(Str\format(
        'Unexpected closing tag: %s, got: %s',
        $expected_tag,
        $bytes,
      ));
    }

    $this->documentText .= $expected_tag;
    $this->popOpenElement();
  }
}
