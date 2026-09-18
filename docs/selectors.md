# Selector matching

`$node->matches($document, $selectors)` tests the node against a CSS selector
list. The caller must supply the owning document; this is unchecked, and
passing a different document yield buggy results. Valid selectors return
`false` for text, comment, and doctype nodes.

```hack
$button->matches($document, 'div.toolbar > .button.primary');
$button->matches($document, '[data-action="save"], #save');
$button->matches($document, ':not(.disabled):nth-child(2n + 1)');
```

## Querying descendants

`$node->querySelectorAll($document, $selectors)` returns a `vec<Node>` of all
matching descendant elements in document order. It excludes the receiver,
text, and comments. An element appears only once even if multiple selectors
in the list match it. No matches produces `vec[]`.

`querySelector()` returns the first such match, or `null`, and stops matching
after finding it. Both methods parse the selector once and reject invalid or
unsupported syntax even when the receiver has no descendants.

```hack
$buttons = $toolbar->querySelectorAll($document, ':scope > .button');
$first_button = $toolbar->querySelector($document, '.button');
```

For both query methods, `:scope` refers to the receiver. Ancestors above the
receiver may participate in selector matching, but returned elements must be
its descendants. The synthetic doctype root can search the whole tree but
cannot itself match `:scope`, since it is not an element.

## Supported syntax

- Type and universal selectors: `div`, `*`.
- IDs, classes, and compounds: `#save`, `.primary`, `button.primary#save`.
- Attribute presence and all six value operators: `[name]`, `=`, `~=`, `|=`,
  `^=`, `$=`, `*=`. Values can be quoted strings or CSS identifiers. The `i`
  and `s` flags explicitly select ASCII-insensitive or sensitive matching.
- Comma-separated selector lists.
- Descendant, child, adjacent sibling, and subsequent sibling combinators:
  space, `>`, `+`, `~`.
- `:scope`, `:root`, and `:empty`.
- `:first-child`, `:last-child`, `:only-child`, and their `-of-type` variants.
- `:nth-child()`, `:nth-last-child()`, `:nth-of-type()`, and
  `:nth-last-of-type()`, with integers, `odd`, `even`, or `An+B` expressions.
- `:not()`, `:is()`, and `:where()`, including nested selector lists and
  complex selectors.
- CSS identifier/string escapes, Unicode names, and comments.

Type and attribute names use HTML case-insensitive matching. IDs and classes
are case-sensitive. Attribute values follow HTML's default case rules unless
overridden by `i` or `s`; custom `data-*` values are case-sensitive by default.
Attribute-name matching also remains case-insensitive inside embedded SVG;
only the first case-equivalent attribute is retained. See the
[documented SVG limitation](./quirks-and-oddities.md#attribute-names-and-embedded-svg).

`:scope` refers to the node receiving `matches()`, including inside logical
pseudo-classes. Since this library uses a doctype node as the document root,
`:root` matches elements directly beneath it. Sibling positions count only
elements. `:empty` ignores comments and zero-length text nodes, but any
nonempty text, including whitespace, prevents a match.

## Errors and current limits

The complete selector is parsed before matching. Invalid or unsupported
syntax raises `InvalidSelectorException`, even when an earlier selector in
the list would match. `:is()` and `:where()` use forgiving lists: invalid or
unsupported branches are discarded, and an empty list matches nothing.
`:not()` uses a strict list.

This first implementation does not support namespaces, pseudo-elements,
browser-state pseudo-classes (such as `:hover`, `:focus`, or `:checked`),
`:has()`, `:lang()`, or the `of <selector-list>` argument to `:nth-child()`.
It does not model XML, SVG namespace rules, or quirks mode. Unterminated
strings/comments and unbalanced delimiters are rejected. Logical selector
nesting is limited to 64 levels; nth integers are limited to 10 characters,
including any sign.
Some valid placements of comments inside nth expressions are rejected; see
the [selector comment quirk](./quirks-and-oddities.md#comments-in-nth-expressions).
