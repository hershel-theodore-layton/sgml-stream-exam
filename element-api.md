# Element API

"Attributions and copyright licensing" by Mozilla Contributors, licensed under CC-BY-SA 2.5
Licensed under: https://creativecommons.org/licenses/by-sa/2.5/
Sourced from: https://developer.mozilla.org/en-US/docs/Web/API/Node
Sourced from: https://developer.mozilla.org/en-US/docs/Web/API/Element
Sourced from: https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement

_Converted to Markdown by an LLM_

## Node Prototype: Instance Properties

| Name | State | Is Immutable | Description |
| :--- | :--- | :--- | :--- |
| `Node.childNodes` | `See Also` | Yes | _`Element.children`, implemented with `->getChildren().`_ |
| `Node.firstChild` | `Implemented` | Yes | _Implemented with `->getFirstChild()` and `->getFirstChildx()`._ |
| `Node.lastChild` | `Implemented` | Yes | _Implemented with `->getLastChild()` and `->getLastChildx()`._ |
| `Node.nextSibling` | `Missing` | Yes | _Implemented with `->getNextSibling()`_ |
| `Node.nodeName` | `See Also` | Yes | _`Element.tagName`, which implemented with `->getName()`._ |
| `Node.nodeType` | `Missing` | Yes | Returns an unsigned short representing the type of the node (e.g., ELEMENT_NODE = 1). |
| `Node.nodeValue` | `Missing` | No | Returns / Sets the value of the current node. |
| `Node.parentElement` | `See Also` | Yes | _`Node.parentNode` does the same thing, since the parent of a non-element is always an element. This was done by making doctype the parent of doctype._ |
| `Node.parentNode` | `Implemented` | Yes | _Implemented with `->getParent($document)`. Requires an explicit document to prevent circular object references._ |
| `Node.previousSibling` | `Implemented` | Yes | _Implemented with `->getPreviousSibling()`_ |
| `Node.textContent` | `Implemented` | No | _Implemented as `->getTextContent()`_ |

## Node Prototype: Instance Methods

| Name | State | Is Immutable | Description |
| :--- | :--- | :--- | :--- |
| `Node.compareDocumentPosition()` | `Missing` | Yes | Compares the position of the current node against another node in any other document. |
| `Node.contains()` | `Missing` | Yes | Returns true or false value indicating whether or not a node is a descendant of the calling node. |
| `Node.getRootNode()` | `Missing` | Yes | Returns the context object's root which optionally includes the shadow root if it is available. |
| `Node.hasChildNodes()` | `Missing` | Yes | Returns a boolean value indicating whether or not the element has any child nodes. |
| `Node.isEqualNode()` | `Missing` | Yes | Returns a boolean value which indicates whether or not two nodes are of the same type and all their defining data points match. |
| `Node.isSameNode()` | `See Also` | Yes | _The operator `===`_ |

## Element Prototype: Instance Properties

| Name | State | Is Immutable | Description |
| :--- | :--- | :--- | :--- |
| `Element.attributes` | `Implemented` | Yes | _Implemented as `->getAttributes()`_ |
| `Element.childElementCount` | `Implemented` | Yes | _Implemented with `->getChildElementCount()`._ |
| `Element.children` | `Implemented` | Yes | _Implemented as `->getChildren()`_ |
| `Element.classList` | `Implemented` | Yes | _Implemented as `->getClassList()`._ |
| `Element.className` | `Implemented` | No | _Implemented with `->getClassName()`._ |
| `Element.firstElementChild` | `Missing` | Yes | Returns the first child element of this element. |
| `Element.id` | `Implemented` | No | _Implemented with `->getId().`_ |
| `Element.innerHTML` | `Implemented` | No | _Implemented at `->getInnerHTML($document)`._ |
| `Element.lastElementChild` | `Missing` | Yes | Returns the last child element of this element. |
| `Element.localName` | `See also` | Yes | _`Node.tagName` which is implemented with `->getName()`._ |
| `Element.nextElementSibling` | `Missing` | Yes | An Element, the element immediately following the given one in the tree, or null if there's no sibling node. |
| `Element.outerHTML` | `Implemented` | No | _Implemented with `->getOuterHTML($document)`. Requires an explicit document for memory consumption reasons._ |
| `Element.previousElementSibling` | `Missing` | Yes | An Element, the element immediately preceding the given one in the tree, or null if there is no sibling element. |
| `Element.tagName` | `Implemented` | Yes | _Implemented with `->getName()` which returns the case-sensitive tagName or the special Node::...\_NAME constants._ |

## Element Prototype: Instance Methods

| Name | State | Is Immutable | Description |
| :--- | :--- | :--- | :--- |
| `Element.closest()` | `Missing` | Yes | Returns the Element which is the closest ancestor of the current element (or the current element itself) which matches the selectors given in parameter. |
| `Element.getAttribute()` | `Missing` | Yes | Retrieves the value of the named attribute from the current node and returns it as a string. |
| `Element.getAttributeNames()` | `Missing` | Yes | Returns an array of attribute names from the current element. |
| `Element.getAttributeNode()` | `Missing` | Yes | Retrieves the node representation of the named attribute from the current node and returns it as an Attr. |
| `Element.getElementById()` | `Implemented` | Yes | _Implemented with `->getElementById($id)` and `->getElementByidx($id)`._ |
| `Element.getElementsByClassName()` | `Missing` | Yes | Returns a live HTMLCollection that contains all descendants of the current element that possess the list of classes given in the parameter. |
| `Element.getElementsByTagName()` | `Missing` | Yes | Returns a live HTMLCollection containing all descendant elements, of a particular tag name, from the current element. |
| `Element.hasAttribute()` | `Missing` | Yes | Returns a boolean value indicating if the element has the specified attribute or not. |
| `Element.hasAttributes()` | `Missing` | Yes | Returns a boolean value indicating if the element has one or more HTML attributes present. |
| `Element.matches()` | `Missing` | Yes | Returns a boolean value indicating whether or not the element would be selected by the specified selector string. |
| `Element.querySelector()` | `Missing` | Yes | Returns the first Node which matches the specified selector string relative to the element. |
| `Element.querySelectorAll()` | `Missing` | Yes | Returns a NodeList of nodes which match the specified selector string relative to the element. |

## HTMLElement Prototype: Instance Properties

| Name | State | Is Immutable | Description |
| :--- | :--- | :--- | :--- |
| `HTMLElement.dataset` | `Missing` | Yes | Returns a DOMStringMap with which script can read and write the element's custom data attributes (data-*). |

# Intentionally Not Implemented

## Modifies the Document

| Name | State | Is Immutable | Description |
| :--- | :--- | :--- | :--- |
| `Node.appendChild()` | `Not Implemented` | No | _Mutates._ |
| `Node.insertBefore()` | `Not Implemented` | No | _Mutates._ |
| `Node.normalize()` | `Not Implemented` | No | _Mutates._ |
| `Node.removeChild()` | `Not Implemented` | No | _Mutates._ |
| `Node.replaceChild()` | `Not Implemented` | No | _Mutates._ |
| `Element.after()` | `Not Implemented` | No | _Mutates._ |
| `Element.append()` | `Not Implemented` | No | _Mutates._ |
| `Element.before()` | `Not Implemented` | No | _Mutates._ |
| `Element.insertAdjacentElement()` | `Not Implemented` | No | _Mutates._ |
| `Element.insertAdjacentHTML()` | `Not Implemented` | No | _Mutates._ |
| `Element.insertAdjacentText()` | `Not Implemented` | No | _Mutates._ |
| `Element.moveBefore()` | `Not Implemented` | No | _Mutates._ |
| `Element.prepend()` | `Not Implemented` | No | _Mutates._ |
| `Element.remove()` | `Not Implemented` | No | _Mutates._ |
| `Element.removeAttribute()` | `Not Implemented` | No | _Mutates._ |
| `Element.removeAttributeNode()` | `Not Implemented` | No | _Mutates._ |
| `Element.removeAttributeNS()` | `Not Implemented` | No | _Mutates._ |
| `Element.replaceChildren()` | `Not Implemented` | No | _Mutates._ |
| `Element.replaceWith()` | `Not Implemented` | No | _Mutates._ |
| `Element.setAttribute()` | `Not Implemented` | No | _Mutates._ |
| `Element.setAttributeNode()` | `Not Implemented` | No | _Mutates._ |
| `Element.setAttributeNodeNS()` | `Not Implemented` | No | _Mutates._ |
| `Element.setAttributeNS()` | `Not Implemented` | No | _Mutates._ |
| `Element.setHTML()` | `Not Implemented` | No | _Mutates._ |
| `Element.setHTMLUnsafe()` | `Not Implemented` | No | _Mutates._ |
| `Element.toggleAttribute()` | `Not Implemented` | No | _Mutates._ |

## Reflects a single attribute

| Name | State | Is Immutable | Description |
| :--- | :--- | :--- | :--- |
| `HTMLElement.accessKey` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.accessKeyLabel` | `Not Implemented` | Yes | _Use getAttribute._ |
| `HTMLElement.autocapitalize` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.autofocus` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.autocorrect` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.contentEditable` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.dir` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.draggable` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.enterKeyHint` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.hidden` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.inert` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.inputMode` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.isContentEditable` | `Not Implemented` | Yes | _Use getAttribute._ |
| `HTMLElement.lang` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.nonce` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.popover` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.spellcheck` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.style` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.tabIndex` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.title` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.translate` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.virtualKeyboardPolicy` | `Not Implemented` | No | _Use getAttribute._ |
| `HTMLElement.writingSuggestions` | `Not Implemented` | No | _Use getAttribute._ |

## Required information is not present

| Name | State | Is Immutable | Description |
| :--- | :--- | :--- | :--- |
| `Node.baseURI` | `Not Implemented` | Yes | _Unknowable._ |
| `Node.isConnected` | `Not Implemented` | Yes | _Unknowable._ |

## Requires knowledge of all possible elements

| Name | State | Is Immutable | Description |
| :--- | :--- | :--- | :--- |
| `Node.isDefaultNamespace()` | `Not Implemented` | Yes | _Namespaces._ |
| `Node.lookupPrefix()` | `Not Implemented` | Yes | _Namespaces._ |
| `Node.lookupNamespaceURI()` | `Not Implemented` | Yes | _Namespaces._ |
| `Element.namespaceURI` | `Not Implemented` | Yes | _Namespaces._ |
| `Element.prefix` | `Not Implemented` | Yes | _Namespaces._ |
| `Element.getAttributeNodeNS()` | `Not Implemented` | Yes | _Namespaces._ |
| `Element.getAttributeNS()` | `Not Implemented` | Yes | _Namespaces._ |
| `Element.getElementsByTagNameNS()` | `Not Implemented` | Yes | _Namespaces._ |
| `Element.hasAttributeNS()` | `Not Implemented` | Yes | _Namespaces._ |

## Requires Shadow DOM

| Name | State | Is Immutable | Description |
| :--- | :--- | :--- | :--- |
| `Element.assignedSlot` | `Not Implemented` | Yes | _Requires Shadow DOM._ |
| `Element.attachShadow()` | `Not Implemented` | No | _Requires Shadow DOM._ |
| `Element.part` | `Not Implemented` | No | _Requires Shadow DOM._ |
| `Element.shadowRoot` | `Not Implemented` | Yes | _Requires Shadow DOM._ |
| `Element.slot` | `Not Implemented` | No | _Requires Shadow DOM._ |
| `Element.getHTML()` | `Not Implemented` | Yes | _Requires Shadow DOM._ |
| `HTMLElement.attachInternals()` | `Not Implemented` | No | _Requires Shadow DOM._ |

## Requires CSS

| Name | State | Is Immutable | Description |
| :--- | :--- | :--- | :--- |
| `HTMLElement.anchorElement` | `Not Implemented` | Yes | _CSS._ |
| `Element.elementTiming` | `Not Implemented` | No | _CSS._ |
| `Element.clientHeight` | `Not Implemented` | Yes | _CSS._ |
| `Element.clientLeft` | `Not Implemented` | Yes | _CSS._ |
| `Element.clientTop` | `Not Implemented` | Yes | _CSS._ |
| `Element.clientWidth` | `Not Implemented` | Yes | _CSS._ |
| `Element.currentCSSZoom` | `Not Implemented` | Yes | _CSS._ |
| `Element.scrollHeight` | `Not Implemented` | Yes | _CSS._ |
| `Element.scrollLeft` | `Not Implemented` | No | _CSS._ |
| `Element.scrollLeftMax` | `Not Implemented` | Yes | _CSS._ |
| `Element.scrollTop` | `Not Implemented` | No | _CSS._ |
| `Element.scrollTopMax` | `Not Implemented` | Yes | _CSS._ |
| `Element.scrollWidth` | `Not Implemented` | Yes | _CSS._ |
| `Element.animate()` | `Not Implemented` | No | _CSS._ |
| `Element.checkVisibility()` | `Not Implemented` | Yes | _CSS._ |
| `Element.computedStyleMap()` | `Not Implemented` | Yes | _CSS._ |
| `Element.getAnimations()` | `Not Implemented` | Yes | _CSS._ |
| `Element.getBoundingClientRect()` | `Not Implemented` | Yes | _CSS._ |
| `Element.getBoxQuads()` | `Not Implemented` | Yes | _CSS._ |
| `Element.getClientRects()` | `Not Implemented` | Yes | _CSS._ |
| `Element.scroll()` | `Not Implemented` | No | _CSS._ |
| `Element.scrollBy()` | `Not Implemented` | No | _CSS._ |
| `Element.scrollIntoView()` | `Not Implemented` | No | _CSS._ |
| `Element.scrollIntoViewIfNeeded()` | `Not Implemented` | No | _CSS._ |
| `Element.scrollTo()` | `Not Implemented` | No | _CSS._ |
| `HTMLElement.attributeStyleMap` | `Not Implemented` | Yes | _CSS._ |
| `HTMLElement.innerText` | `Missing` | No | _CSS._ |
| `HTMLElement.offsetHeight` | `Not Implemented` | Yes | _CSS._ |
| `HTMLElement.offsetLeft` | `Not Implemented` | Yes | _CSS._ |
| `HTMLElement.offsetParent` | `Not Implemented` | Yes | _CSS._ |
| `HTMLElement.offsetTop` | `Not Implemented` | Yes | _CSS._ |
| `HTMLElement.offsetWidth` | `Not Implemented` | Yes | _CSS._ |
| `HTMLElement.outerText` | `Not Implemented` | No | _CSS._ |

## Require a user

| Name | State | Is Immutable | Description |
| :--- | :--- | :--- | :--- |
| `Element.ariaNotify()` | `Not Implemented` | Yes | _Non-interactive._ |
| `Element.hasPointerCapture()` | `Not Implemented` | Yes | _Non-interactive._ |
| `Element.releasePointerCapture()` | `Not Implemented` | No | _Non-interactive._ |
| `Element.requestFullscreen()` | `Not Implemented` | No | _Non-interactive._ |
| `Element.requestPointerLock()` | `Not Implemented` | No | _Non-interactive._ |
| `Element.setCapture()` | `Not Implemented` | No | _Non-interactive._ |
| `Element.setPointerCapture()` | `Not Implemented` | No | _Non-interactive._ |
| `HTMLElement.editContext` | `Not Implemented` | No | _Non-interactive._ |
| `HTMLElement.blur()` | `Not Implemented` | No | _Non-interactive._ |
| `HTMLElement.click()` | `Not Implemented` | No | _Non-interactive._ |
| `HTMLElement.focus()` | `Not Implemented` | No | _Non-interactive._ |
| `HTMLElement.hidePopover()` | `Not Implemented` | No | _Non-interactive._ |
| `HTMLElement.showPopover()` | `Not Implemented` | No | _Non-interactive._ |
| `HTMLElement.togglePopover()` | `Not Implemented` | No | _Non-interactive._ |

## By Reason

| Name | State | Is Immutable | Description |
| :--- | :--- | :--- | :--- |
| `Node.ownerDocument` | `Not implemented` | Yes | _This would result in circular object references._ |
| `Node.cloneNode()` | `Not Implemented` | Yes | _This is not needed if you cannot reinsert nodes. The Document is immutable._ |
