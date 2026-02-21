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
| `Node.baseURI` | `Missing` | Yes | Returns a string representing the base URL of the document containing the Node. |
| `Node.childNodes` | `Missing` | Yes | Returns a live NodeList containing all the children of this node (including elements, text and comments). NodeList being live means that if the children of the Node change, the NodeList object is automatically updated. |
| `Node.firstChild` | `Missing` | Yes | Returns a Node representing the first direct child node of the node, or null if the node has no child. |
| `Node.isConnected` | `Missing` | Yes | A boolean indicating whether or not the Node is connected (directly or indirectly) to the context object, e.g., the Document object in the case of the normal DOM, or the ShadowRoot in the case of a shadow DOM. |
| `Node.lastChild` | `Missing` | Yes | Returns a Node representing the last direct child node of the node, or null if the node has no child. |
| `Node.nextSibling` | `Missing` | Yes | Returns a Node representing the next node in the tree, or null if there isn't such node. |
| `Node.nodeName` | `Missing` | Yes | Returns a string containing the name of the Node. The structure of the name will differ with the node type. E.g. An HTMLElement will contain the name of the corresponding tag, like 'AUDIO' for an HTMLAudioElement, a Text node will have the '#text' string, or a Document node will have the '#document' string. |
| `Node.nodeType` | `Missing` | Yes | Returns an unsigned short representing the type of the node. Possible values are: Name Value ELEMENT_NODE 1 ATTRIBUTE_NODE 2 TEXT_NODE 3 CDATA_SECTION_NODE 4 PROCESSING_INSTRUCTION_NODE 7 COMMENT_NODE 8 DOCUMENT_NODE 9 DOCUMENT_TYPE_NODE 10 DOCUMENT_FRAGMENT_NODE 11 |
| `Node.nodeValue` | `Missing` | No | Returns / Sets the value of the current node. |
| `Node.ownerDocument` | `Missing` | Yes | Returns the Document that this node belongs to. If the node is itself a document, returns null. |
| `Node.parentNode` | `Missing` | Yes | Returns a Node that is the parent of this node. If there is no such node — for example, if this node is the top of the tree, or if it doesn't participate in a tree — this property returns null. |
| `Node.parentElement` | `Missing` | Yes | Returns an Element that is the parent of this node. If the node has no parent, or if that parent is not an Element, this property returns null. |
| `Node.previousSibling` | `Missing` | Yes | Returns a Node representing the previous node in the tree, or null if there isn't such node. |
| `Node.textContent` | `Missing` | No | Returns / Sets the textual content of an element and all its descendants. |

## Node Prototype: Instance Methods

| Name | State | Is Immutable | Description |
| :--- | :--- | :--- | :--- |
| `Node.appendChild()` | `Missing` | No | Adds the specified childNode argument as the last child to the current node. If the argument referenced an existing node on the DOM tree, the node will be detached from its current position and attached at the new position. |
| `Node.cloneNode()` | `Missing` | Yes | Clone a Node, and optionally, all of its contents. By default, it clones the content of the node. |
| `Node.compareDocumentPosition()` | `Missing` | Yes | Compares the position of the current node against another node in any other document. |
| `Node.contains()` | `Missing` | Yes | Returns true or false value indicating whether or not a node is a descendant of the calling node. |
| `Node.getRootNode()` | `Missing` | Yes | Returns the context object's root which optionally includes the shadow root if it is available. |
| `Node.hasChildNodes()` | `Missing` | Yes | Returns a boolean value indicating whether or not the element has any child nodes. |
| `Node.insertBefore()` | `Missing` | No | Inserts a Node before the reference node as a child of a specified parent node. |
| `Node.isDefaultNamespace()` | `Missing` | Yes | Accepts a namespace URI as an argument and returns a boolean value with a value of true if the namespace is the default namespace on the given node or false if not. |
| `Node.isEqualNode()` | `Missing` | Yes | Returns a boolean value which indicates whether or not two nodes are of the same type and all their defining data points match. |
| `Node.isSameNode()` | `Missing` | Yes | Returns a boolean value indicating whether or not the two nodes are the same (that is, they reference the same object). |
| `Node.lookupPrefix()` | `Missing` | Yes | Returns a string containing the prefix for a given namespace URI, if present, and null if not. When multiple prefixes are possible, the result is implementation-dependent. |
| `Node.lookupNamespaceURI()` | `Missing` | Yes | Accepts a prefix and returns the namespace URI associated with it on the given node if found (and null if not). Supplying null for the prefix will return the default namespace. |
| `Node.normalize()` | `Missing` | No | Clean up all the text nodes under this element (merge adjacent, remove empty). |
| `Node.removeChild()` | `Missing` | No | Removes a child node from the current element, which must be a child of the current node. |
| `Node.replaceChild()` | `Missing` | No | Replaces one child Node of the current one with the second one given in parameter. |

## Element Prototype: Instance Properties

| Name | State | Is Immutable | Description |
| :--- | :--- | :--- | :--- |
| `Element.assignedSlot` | `Missing` | Yes | Returns a HTMLSlotElement representing the `slot` the node is inserted in. |
| `Element.attributes` | `Missing` | Yes | Returns a NamedNodeMap object containing the assigned attributes of the corresponding HTML element. |
| `Element.childElementCount` | `Missing` | Yes | Returns the number of child elements of this element. |
| `Element.children` | `Missing` | Yes | Returns the child elements of this element. |
| `Element.classList` | `Missing` | Yes | Returns a DOMTokenList containing the list of class attributes. |
| `Element.className` | `Missing` | No | A string representing the class of the element. |
| `Element.clientHeight` | `Missing` | Yes | Returns a number representing the inner height of the element. |
| `Element.clientLeft` | `Missing` | Yes | Returns a number representing the width of the left border of the element. |
| `Element.clientTop` | `Missing` | Yes | Returns a number representing the width of the top border of the element. |
| `Element.clientWidth` | `Missing` | Yes | Returns a number representing the inner width of the element. |
| `Element.currentCSSZoom` | `Missing` | Yes | A number indicating the effective zoom size of the element, or 1.0 if the element is not rendered. |
| `Element.elementTiming` | `Missing` | No | [Experimental] A string reflecting the elementtiming attribute which marks an element for observation in the PerformanceElementTiming API. |
| `Element.firstElementChild` | `Missing` | Yes | Returns the first child element of this element. |
| `Element.id` | `Missing` | No | A string representing the id of the element. |
| `Element.innerHTML` | `Missing` | No | A string representing the markup of the element's content. |
| `Element.lastElementChild` | `Missing` | Yes | Returns the last child element of this element. |
| `Element.localName` | `Missing` | Yes | A string representing the local part of the qualified name of the element. |
| `Element.namespaceURI` | `Missing` | Yes | The namespace URI of the element, or null if it is no namespace. |
| `Element.nextElementSibling` | `Missing` | Yes | An Element, the element immediately following the given one in the tree, or null if there's no sibling node. |
| `Element.outerHTML` | `Missing` | No | A string representing the markup of the element including its content. When used as a setter, replaces the element with nodes parsed from the given string. |
| `Element.part` | `Missing` | No | Represents the part identifier(s) of the element (i.e., set using the part attribute), returned as a DOMTokenList. |
| `Element.prefix` | `Missing` | Yes | A string representing the namespace prefix of the element, or null if no prefix is specified. |
| `Element.previousElementSibling` | `Missing` | Yes | An Element, the element immediately preceding the given one in the tree, or null if there is no sibling element. |
| `Element.scrollHeight` | `Missing` | Yes | Returns a number representing the scroll view height of an element. |
| `Element.scrollLeft` | `Missing` | No | A number representing the left scroll offset of the element. |
| `Element.scrollLeftMax` | `Missing` | Yes | [Non-standard] Returns a number representing the maximum left scroll offset possible for the element. |
| `Element.scrollTop` | `Missing` | No | A number representing number of pixels the top of the element is scrolled vertically. |
| `Element.scrollTopMax` | `Missing` | Yes | [Non-standard] Returns a number representing the maximum top scroll offset possible for the element. |
| `Element.scrollWidth` | `Missing` | Yes | Returns a number representing the scroll view width of the element. |
| `Element.shadowRoot` | `Missing` | Yes | Returns the open shadow root that is hosted by the element, or null if no open shadow root is present. |
| `Element.slot` | `Missing` | No | Returns the name of the shadow DOM slot the element is inserted in. |
| `Element.tagName` | `Missing` | Yes | Returns a string with the name of the tag for the given element. |

## Element Prototype: Instance Methods

| Name | State | Is Immutable | Description |
| :--- | :--- | :--- | :--- |
| `Element.after()` | `Missing` | No | Inserts a set of Node objects or strings in the children list of the Element's parent, just after the Element. |
| `Element.animate()` | `Missing` | No | A shortcut method to create and run an animation on an element. Returns the created Animation object instance. |
| `Element.ariaNotify()` | `Missing` | Yes | [Experimental] [Non-standard] Specifies that a given string of text should be announced by a screen reader. |
| `Element.append()` | `Missing` | No | Inserts a set of Node objects or strings after the last child of the element. |
| `Element.attachShadow()` | `Missing` | No | Attaches a shadow DOM tree to the specified element and returns a reference to its ShadowRoot. |
| `Element.before()` | `Missing` | No | Inserts a set of Node objects or strings in the children list of the Element's parent, just before the Element. |
| `Element.checkVisibility()` | `Missing` | Yes | Returns whether an element is expected to be visible or not based on configurable checks. |
| `Element.closest()` | `Missing` | Yes | Returns the Element which is the closest ancestor of the current element (or the current element itself) which matches the selectors given in parameter. |
| `Element.computedStyleMap()` | `Missing` | Yes | Returns a StylePropertyMapReadOnly interface which provides a read-only representation of a CSS declaration block that is an alternative to CSSStyleDeclaration. |
| `Element.getAnimations()` | `Missing` | Yes | Returns an array of Animation objects currently active on the element. |
| `Element.getAttribute()` | `Missing` | Yes | Retrieves the value of the named attribute from the current node and returns it as a string. |
| `Element.getAttributeNames()` | `Missing` | Yes | Returns an array of attribute names from the current element. |
| `Element.getAttributeNode()` | `Missing` | Yes | Retrieves the node representation of the named attribute from the current node and returns it as an Attr. |
| `Element.getAttributeNodeNS()` | `Missing` | Yes | Retrieves the node representation of the attribute with the specified name and namespace, from the current node and returns it as an Attr. |
| `Element.getAttributeNS()` | `Missing` | Yes | Retrieves the value of the attribute with the specified namespace and name from the current node and returns it as a string. |
| `Element.getBoundingClientRect()` | `Missing` | Yes | Returns the size of an element and its position relative to the viewport. |
| `Element.getBoxQuads()` | `Missing` | Yes | [Experimental] Returns a list of DOMQuad objects representing the CSS fragments of the node. |
| `Element.getClientRects()` | `Missing` | Yes | Returns a collection of rectangles that indicate the bounding rectangles for each line of text in a client. |
| `Element.getElementsByClassName()` | `Missing` | Yes | Returns a live HTMLCollection that contains all descendants of the current element that possess the list of classes given in the parameter. |
| `Element.getElementsByTagName()` | `Missing` | Yes | Returns a live HTMLCollection containing all descendant elements, of a particular tag name, from the current element. |
| `Element.getElementsByTagNameNS()` | `Missing` | Yes | Returns a live HTMLCollection containing all descendant elements, of a particular tag name and namespace, from the current element. |
| `Element.getHTML()` | `Missing` | Yes | Returns the DOM content of the element as an HTML string, optionally including any shadow DOM. |
| `Element.hasAttribute()` | `Missing` | Yes | Returns a boolean value indicating if the element has the specified attribute or not. |
| `Element.hasAttributeNS()` | `Missing` | Yes | Returns a boolean value indicating if the element has the specified attribute, in the specified namespace, or not. |
| `Element.hasAttributes()` | `Missing` | Yes | Returns a boolean value indicating if the element has one or more HTML attributes present. |
| `Element.hasPointerCapture()` | `Missing` | Yes | Indicates whether the element on which it is invoked has pointer capture for the pointer identified by the given pointer ID. |
| `Element.insertAdjacentElement()` | `Missing` | No | Inserts a given element node at a given position relative to the element it is invoked upon. |
| `Element.insertAdjacentHTML()` | `Missing` | No | Parses the text as HTML or XML and inserts the resulting nodes into the tree in the position given. |
| `Element.insertAdjacentText()` | `Missing` | No | Inserts a given text node at a given position relative to the element it is invoked upon. |
| `Element.matches()` | `Missing` | Yes | Returns a boolean value indicating whether or not the element would be selected by the specified selector string. |
| `Element.moveBefore()` | `Missing` | No | Moves a given Node inside the invoking node as a direct child, before a given reference node, without removing and then inserting the node. |
| `Element.prepend()` | `Missing` | No | Inserts a set of Node objects or strings before the first child of the element. |
| `Element.querySelector()` | `Missing` | Yes | Returns the first Node which matches the specified selector string relative to the element. |
| `Element.querySelectorAll()` | `Missing` | Yes | Returns a NodeList of nodes which match the specified selector string relative to the element. |
| `Element.releasePointerCapture()` | `Missing` | No | Releases (stops) pointer capture that was previously set for a specific PointerEvent. |
| `Element.remove()` | `Missing` | No | Removes the element from the children list of its parent. |
| `Element.removeAttribute()` | `Missing` | No | Removes the named attribute from the current node. |
| `Element.removeAttributeNode()` | `Missing` | No | Removes the node representation of the named attribute from the current node. |
| `Element.removeAttributeNS()` | `Missing` | No | Removes the attribute with the specified name and namespace, from the current node. |
| `Element.replaceChildren()` | `Missing` | No | Replaces the existing children of a Node with a specified new set of children. |
| `Element.replaceWith()` | `Missing` | No | Replaces the element in the children list of its parent with a set of Node objects or strings. |
| `Element.requestFullscreen()` | `Missing` | No | Asynchronously asks the browser to make the element fullscreen. |
| `Element.requestPointerLock()` | `Missing` | No | Allows to asynchronously ask for the pointer to be locked on the given element. |
| `Element.scroll()` | `Missing` | No | Scrolls to a particular set of coordinates inside a given element. |
| `Element.scrollBy()` | `Missing` | No | Scrolls an element by the given amount. |
| `Element.scrollIntoView()` | `Missing` | No | Scrolls the page until the element gets into the view. |
| `Element.scrollIntoViewIfNeeded()` | `Missing` | No | [Non-standard] Scrolls the current element into the visible area of the browser window if it's not already within the visible area of the browser window. Use the standard Element.scrollIntoView() instead. |
| `Element.scrollTo()` | `Missing` | No | Scrolls to a particular set of coordinates inside a given element. |
| `Element.setAttribute()` | `Missing` | No | Sets the value of a named attribute of the current node. |
| `Element.setAttributeNode()` | `Missing` | No | Sets the node representation of the named attribute from the current node. |
| `Element.setAttributeNodeNS()` | `Missing` | No | Sets the node representation of the attribute with the specified name and namespace, from the current node. |
| `Element.setAttributeNS()` | `Missing` | No | Sets the value of the attribute with the specified name and namespace, from the current node. |
| `Element.setCapture()` | `Missing` | No | [Non-standard] [Deprecated] Sets up mouse event capture, redirecting all mouse events to this element. |
| `Element.setHTML()` | `Missing` | No | [Secure context] Parses and sanitizes a string of HTML into a document fragment, which then replaces the element's original subtree in the DOM. |
| `Element.setHTMLUnsafe()` | `Missing` | No | Parses a string of HTML into a document fragment, without sanitization, which then replaces the element's original subtree in the DOM. The HTML string may include declarative shadow roots, which would be parsed as template elements if the HTML was set using Element.innerHTML. |
| `Element.setPointerCapture()` | `Missing` | No | Designates a specific element as the capture target of future pointer events. |
| `Element.toggleAttribute()` | `Missing` | No | Toggles a boolean attribute, removing it if it is present and adding it if it is not present, on the specified element. |

## HTMLElement Prototype: Instance Properties

| Name | State | Is Immutable | Description |
| :--- | :--- | :--- | :--- |
| `HTMLElement.accessKey` | `Missing` | No | A string representing the access key assigned to the element. |
| `HTMLElement.accessKeyLabel` | `Missing` | Yes | Returns a string containing the element's assigned access key. |
| `HTMLElement.anchorElement` | `Missing` | Yes | [Non-standard] [Experimental] Returns a reference to the element's anchor element, or null if it doesn't have one. |
| `HTMLElement.attributeStyleMap` | `Missing` | Yes | A StylePropertyMap representing the declarations of the element's style attribute. |
| `HTMLElement.autocapitalize` | `Missing` | No | A string that represents the element's capitalization behavior for user input. Valid values are: none, off, on, characters, words, sentences. |
| `HTMLElement.autofocus` | `Missing` | No | A boolean value reflecting the autofocus HTML global attribute, which indicates whether the control should be focused when the page loads, or when dialog or popover become shown if specified in an element inside `` `<dialog>` `` elements or elements whose popover attribute is set. |
| `HTMLElement.autocorrect` | `Missing` | No | A boolean that represents whether or not text input by a user should be automatically corrected. This reflects the autocorrect HTML global attribute. |
| `HTMLElement.contentEditable` | `Missing` | No | A string, where a value of true means the element is editable and a value of false means it isn't. |
| `HTMLElement.dataset` | `Missing` | Yes | Returns a DOMStringMap with which script can read and write the element's custom data attributes (data-*). |
| `HTMLElement.dir` | `Missing` | No | A string, reflecting the dir global attribute, representing the directionality of the element. Possible values are "ltr", "rtl", and "auto". |
| `HTMLElement.draggable` | `Missing` | No | A boolean value indicating if the element can be dragged. |
| `HTMLElement.editContext` | `Missing` | No | [Experimental] Returns the EditContext associated with the element, or null if there isn't one. |
| `HTMLElement.enterKeyHint` | `Missing` | No | A string defining what action label (or icon) to present for the enter key on virtual keyboards. |
| `HTMLElement.hidden` | `Missing` | No | A string or boolean value reflecting the value of the element's hidden attribute. |
| `HTMLElement.inert` | `Missing` | No | A boolean value indicating whether the user agent must act as though the given node is absent for the purposes of user interaction events, in-page text searches ("find in page"), and text selection. |
| `HTMLElement.innerText` | `Missing` | No | Represents the rendered text content of a node and its descendants. As a getter, it approximates the text the user would get if they highlighted the contents of the element with the cursor and then copied it to the clipboard. As a setter, it replaces the content inside the selected element, converting any line breaks into `` `<br>` `` elements. |
| `HTMLElement.inputMode` | `Missing` | No | A string value reflecting the value of the element's inputmode attribute. |
| `HTMLElement.isContentEditable` | `Missing` | Yes | Returns a boolean value indicating whether or not the content of the element can be edited. |
| `HTMLElement.lang` | `Missing` | No | A string representing the language of an element's attributes, text, and element contents. |
| `HTMLElement.nonce` | `Missing` | No | Returns the cryptographic number used once that is used by Content Security Policy to determine whether a given fetch will be allowed to proceed. |
| `HTMLElement.offsetHeight` | `Missing` | Yes | Returns a double containing the height of an element, relative to the layout. |
| `HTMLElement.offsetLeft` | `Missing` | Yes | Returns a double, the distance from this element's left border to its offsetParent's left border. |
| `HTMLElement.offsetParent` | `Missing` | Yes | An Element that is the element from which all offset calculations are currently computed. |
| `HTMLElement.offsetTop` | `Missing` | Yes | Returns a double, the distance from this element's top border to its offsetParent's top border. |
| `HTMLElement.offsetWidth` | `Missing` | Yes | Returns a double containing the width of an element, relative to the layout. |
| `HTMLElement.outerText` | `Missing` | No | Represents the rendered text content of a node and its descendants. As a getter, it is the same as HTMLElement.innerText (it represents the rendered text content of an element and its descendants). As a setter, it replaces the selected node and its contents with the given value, converting any line breaks into `` `<br>` `` elements. |
| `HTMLElement.popover` | `Missing` | No | Gets and sets an element's popover state via JavaScript ("auto", "hint", or "manual"), and can be used for feature detection. Reflects the value of the popover global HTML attribute. |
| `HTMLElement.spellcheck` | `Missing` | No | A boolean value that controls the spell-checking hint. It is available on all HTML elements, though it doesn't affect all of them. |
| `HTMLElement.style` | `Missing` | No | A CSSStyleDeclaration representing the declarations of the element's style attribute. |
| `HTMLElement.tabIndex` | `Missing` | No | A long representing the position of the element in the tabbing order. |
| `HTMLElement.title` | `Missing` | No | A string containing the text that appears in a popup box when mouse is over the element. |
| `HTMLElement.translate` | `Missing` | No | A boolean value representing the translation. |
| `HTMLElement.virtualKeyboardPolicy` | `Missing` | No | [Experimental] A string indicating the on-screen virtual keyboard behavior on devices such as tablets, mobile phones, or other devices where a hardware keyboard may not be available, if the element's content is editable (for example, it is an `` `<input>` `` or `` `<textarea>` `` element, or an element with the contenteditable attribute set). |
| `HTMLElement.writingSuggestions` | `Missing` | No | A string indicating if browser-provided writing suggestions should be enabled under the scope of the element or not. |

## HTMLElement Prototype: Instance Methods

| Name | State | Is Immutable | Description |
| :--- | :--- | :--- | :--- |
| `HTMLElement.attachInternals()` | `Missing` | No | Returns an ElementInternals object, and enables a custom element to participate in HTML forms. |
| `HTMLElement.blur()` | `Missing` | No | Removes keyboard focus from the currently focused element. |
| `HTMLElement.click()` | `Missing` | No | Sends a mouse click event to the element. |
| `HTMLElement.focus()` | `Missing` | No | Makes the element the current keyboard focus. |
| `HTMLElement.hidePopover()` | `Missing` | No | Hides a popover element by removing it from the top layer and styling it with display: none. |
| `HTMLElement.showPopover()` | `Missing` | No | Shows a popover element by adding it to the top layer and removing display: none; from its styles. |
| `HTMLElement.togglePopover()` | `Missing` | No | Toggles a popover element between the hidden and showing states. |