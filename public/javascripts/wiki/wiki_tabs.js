//
// Wysiwyg / GreenCloth Wiki Editors
//

// updates the editor data from json returned by ajax request.
function updateEditor(response, tab, id) {
  if(response.status != 200)
    return false;

  var editor   = new HtmlEditor(id);
  var textarea = $("wiki_body-" + id);
  var preview  = $("wiki_preview-" + id);

  if (response.responseJSON.body_preview)
    preview.update(getBackNewLines(response.responseJSON.body_preview));
  else {
    preview.update("");
    editor.setContent( getBackNewLines(response.responseJSON.body_html) || "" );
    textarea.setValue( getBackNewLines(response.responseJSON.body)      || "" );
  }

  if (tab == 'greencloth') {
    showTab($('link-tab-greencloth'), $('tab-edit-greencloth'));
  }
  else if (tab == 'html') {
    showTab($('link-tab-html'), $('tab-edit-html'));
    editor.refresh();
  }
  else if (tab == 'preview') {
    showTab($('link-tab-preview'), $('tab-edit-preview'));
  }
}

function getBackNewLines(str) {
  if (str)
    return str.replace(/__NEW_LINE__/g, '\n').replace(/__TAB_CHAR__/g, '\t');
}

//function getActiveTabLink() {
//  return $$('ul.simple_tabset a.active')[0];
//}

function isTabSelected(link) {return $(link).hasClassName('active')}

function encodedEditorData(wiki_id) {
  var textarea = $('wiki_body-'+wiki_id);
  var visual_editor = new HtmlEditor(wiki_id);
  if (textarea.getValue())
    return textarea.serialize();
  if (visual_editor.content())
    return $H({'wiki[body_html]': visual_editor.content()}).toQueryString();
}

function editorData(editor, wiki_id) {
  var data = "";
  if (editor == 'greencloth')
    data = $('wiki_body-'+wiki_id).getValue();
  else if (editor == 'html') {
    editor = new HtmlEditor(wiki_id);
    data = editor.content();
    if (data == "<br>")
      data = "";
  }
  return data;
}

// requires: :wiki_id, :tab_id, :area_id, :editor, :url, :token
function selectWikiEditorTab(url, options) {
  if (isTabSelected(options.tab_id))
    return false;
  else if (editorData(options.editor, options.wiki_id))
    showTab(options.tab_id, options.area_id);
  else {
    new Ajax.Request(url, {
      asynchronous:true, evalScripts:true, method:'post',
      onComplete:function(request){updateEditor(request, options.editor, options.wiki_id)},
      onLoading:function(request){showTab(options.tab_id, 'tab-edit-loading')},
      parameters:encodedEditorData(options.wiki_id) +
        '&authenticity_token=' +
        encodeURIComponent(options.token)
    });
  }
  return true;
}

/*
if (typeof(nicEditors) != 'undefined') {
  //
  // A generic nicedit button that calls a js function.
  //
  var nicFunctionButton = nicEditorButton.extend({
    mouseClick: function() {
      this.ne.options[this.options.onclick]();
    }
  });

  //
  // nicEdit plugin for crabgrass image popup
  //
  var nicCgImageOptions = {
    buttons: {
      image: {name: 'Add Image', type: 'nicFunctionButton', onclick: 'onImgButtonClick'}
    }
  };
  nicEditors.registerPlugin(nicPlugin,nicCgImageOptions);
}
*/
