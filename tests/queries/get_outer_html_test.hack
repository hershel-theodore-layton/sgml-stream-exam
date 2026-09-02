/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\Tests;

use namespace HH\Lib\C;
use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function get_outer_html_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain
    ->group(__FUNCTION__)
    ->testAsync(
      'getOuterHTML returns expected markup for element nodes',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="parent">
              <span id="child"></span>
            </div>
          </doctype>,
        );
        $root = $doc->getCurrentNode();

        $parent = $root->getElementByIdx($doc, 'parent');
        $child = $root->getElementByIdx($doc, 'child');

        expect($child->getOuterHTML($doc))->toEqual('<span id="child"></span>');
        expect($parent->getOuterHTML($doc))
          ->toEqual('<div id="parent"><span id="child"></span></div>');
      },
    )
    ->testAsync(
      'getOuterHTML preserves text node content (including surrounding whitespace)',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="parent">
              Some text
              <span id="elem"></span>
              More text
            </div>
          </doctype>,
        );
        $root = $doc->getCurrentNode();

        $parent = $root->getElementByIdx($doc, 'parent');
        $children = $parent->getChildren($doc);

        expect(C\count($children))->toEqual(3);

        expect($children[0]->getOuterHTML($doc))->toEqual(' Some text ');
        expect($children[1]->getOuterHTML($doc))->toEqual(
          '<span id="elem"></span>',
        );
        expect($children[2]->getOuterHTML($doc))->toEqual(' More text ');
      },
    )
    ->testAsync(
      'getOuterHTML includes attributes in canonical order (attributes, aria-* & data-*)',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div
              id="elem"
              aria-hidden="true"
              class="btn btn-primary"
              data-action="click"
              title="Button">
              X
            </div>
          </doctype>,
        );
        $root = $doc->getCurrentNode();

        $elem = $root->getElementByIdx($doc, 'elem');

        expect($elem->getOuterHTML($doc))->toEqual(
          '<div id="elem" class="btn btn-primary" title="Button" aria-hidden="true" data-action="click"> X </div>',
        );
      },
    )
    ->testAsync(
      'getOuterHTML for void element does not include a self-closing slash',
      async ()[defaults] ==> {
        $doc = await render_to_document_async(
          <doctype>
            <div id="parent">
              <input id="x" />
            </div>
          </doctype>,
        );
        $root = $doc->getCurrentNode();

        $x = $root->getElementByIdx($doc, 'x');
        expect($x->getOuterHTML($doc))->toEqual('<input id="x">');
      },
    );
}
