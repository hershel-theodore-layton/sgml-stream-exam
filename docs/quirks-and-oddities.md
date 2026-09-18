# Quirks and oddities

## Attribute names and embedded SVG

- **Names ignore ASCII case**, including in SVG. `viewBox` and `viewbox`
  share one entry; the first spelling and value win.
- Lookup, attribute selectors, and `isEqualNode()` use normalized names.
  Equality still compares values exactly.
- `getInnerHTML()` and `getOuterHTML()` preserve the source, including ignored
  attributes. Browser SVG handling can differ.

## Tag-name casing affects node equality

`isEqualNode()` treats `div` and `DIV` as different; tag lookup and selectors
ignore ASCII case. Unlike caller-supplied `data-*` and `aria-*` names, tag
names come from declared constants, so equality preserves their casing.

## The document root is its own parent

Following Portable Hack AST's convention, `getParent()` never returns null.
The synthetic doctype root returns itself; its `getAncestors()` returns
`vec[$root]`. Other ancestor lists end at the root, included once.
**Stop manual parent traversal at the root**, rather than waiting for null.

## Line endings are preserved

Text queries preserve CRLF (`\r\n`) and CR (`\r`); browsers normalize both to
LF (`\n`). This keeps equality assertions against supplied strings predictable.

## HTML-looking content is parsed as markup regardless of context

Pieces that look like tags or comments are parsed as markup even inside
scripts; the `type` attribute does not affect parsing. For example,
`<script type="text/html"><hr></script>` has an `hr` child and empty text
content here, while browsers return the text `<hr>`. Such content can also
cause parsing exceptions.

## Comments in nth expressions

`:nth-child(+/**/n)` is valid in browsers but throws `InvalidSelectorException`
here. Use `:nth-child(+n)` and put comments in Hack code. Other malformed
selectors may be accepted.[^selector-validation]

[^selector-validation]: `[data-code~/**/=x]` is accepted as `[data-code~=x]`, although browsers reject it.
