/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam;

use namespace HH\Lib\{C, Str};
use namespace HTL\SGMLStreamInterfaces;

/**
 * This consumer parses the HTML that is being fed to it. It depends on
 * receiving its input piecewise. This is intended to be used in combination
 * with `PiecewiseStream`. It expects input to be in the format of html-stream
 * and does not parse general HTML. Results may be disappointing if you depend
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

  private bool $inComment = false;
  private bool $isFirstNode = true;

  private Document $document;

  public function __construct(
    private keyset<string> $void_elements = static::STANDARD_VOID_ELEMENTS,
  )[write_props] {
    $this->document = new Document();
  }

  public async function consumeAsync(string $bytes)[defaults]: Awaitable<void> {
    if ($this->isFirstNode) {
      $this->isFirstNode = false;
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

      // We exit early, because the default Document already contains a DOCTYPE.
      return;
    }

    if ($this->inComment) {
      $this->parseHtml($bytes);
      return;
    }

    if (!Str\starts_with($bytes, '<!--')) {
      $this->parseHtml($bytes);
      return;
    }

    // Comments are not implemented by html-stream.
    // Users may have implemented them like so '<!-- text -->'
    // or like so '<!--', ' text ', '-->'.
    // Let's treat '<!-- text -->' as '<!-- text ', '-->',
    // so the code only handles non-closing comment tags.
    $start_comment = Str\strip_suffix($bytes, '-->');
    $this->parseHtml($start_comment);
    if ($start_comment !== $bytes) {
      $this->parseHtml('-->');
    }
  }

  public async function receiveWaitNotificationAsync(
  )[defaults]: Awaitable<void> {}
  public async function flushAsync()[defaults]: Awaitable<void> {}
  public async function theDocumentIsCompleteAsync(
  )[defaults]: Awaitable<void> {
    $this->document->freeze();
  }

  public function toDocument()[]: Document {
    return $this->document;
  }

  private function parseHtml(string $bytes)[defaults]: void {
    if ($this->inComment) {
      $this->document->pushHtmlSource($bytes);
      if (Str\ends_with($bytes, '-->')) {
        $this->document->closeNode();
        $this->inComment = false;
      }
      return;
    }

    if (Str\starts_with($bytes, '<!--')) {
      $this->inComment = true;
      $this->document->addNode(shape(
        'attributes' => dict[],
        'tag_name' => Node::COMMENT,
        'text' => $bytes,
      ));
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

    $this->document->addNode(shape(
      'attributes' => dict[],
      'tag_name' => Node::TXTNODE,
      'text' => $bytes,
    ));
    $this->document->closeNode();
  }

  private function parseOpeningTag(string $bytes)[defaults]: void {
    $rest = Str\strip_prefix($bytes, '<') |> Str\strip_suffix($$, '>');

    list($tag_name, $rest) = _Private\consume_until_space_exclusive($rest);
    $attributes = dict[];

    for (; ; ) {
      list($attribute_name, $end_char, $rest) =
        _Private\consume_until_equals_or_space_inclusive($rest);

      if ($attribute_name === '') {
        if ($end_char !== ' ' || $rest !== '') {
          throw
            new UnexpectedHTMLException('Unable to parse attribute: '.$bytes);
        }

        break;
      }

      if ($end_char === '=') {
        list($value, $rest) = _Private\consume_attribute_value($rest);
        $attributes[$attribute_name] = $value;
      } else if ($end_char === ' ') {
        $attributes[$attribute_name] = '';
      }
    }

    $this->document->addNode(shape(
      'tag_name' => $tag_name,
      'attributes' => $attributes,
      'text' => $bytes,
    ));

    if (C\contains_key($this->void_elements, $tag_name)) {
      $this->document->closeNode();
    }
  }

  private function parseClosingTag(string $bytes)[write_props]: void {
    $expected_tag = '</'.$this->document->getCurrentNode()->getName().'>';

    if ($bytes !== $expected_tag) {
      throw new UnexpectedHTMLException(Str\format(
        'Unexpected closing tag: %s, got: %s',
        $expected_tag,
        $bytes,
      ));
    }

    $this->document->pushHtmlSource($bytes);
    $this->document->closeNode();
  }
}
