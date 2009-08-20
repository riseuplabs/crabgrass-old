//
// Javascript needed for wiki editings.
// If you modify this file, or any of the wiki js files, make sure to run 'rake minify'.
//
//

//
// WIKI EDITING POPUPS
//

// give a radio button group name, return the value of the currently
// selected button.
function activeRadioValue(name) {
  try { return $$('input[name='+name+']').detect(function(e){return $F(e)}).value; } catch(e) {}
}

function insertImage(wikiId) {
  var editor = new HtmlEditor(wikiId);
  var textarea = $('wiki_body-' + wikiId);

  try {
    var assetId = activeRadioValue('image');
    var link = $('link_to_image').checked;
    var size = activeRadioValue('image_size');
    var thumbnails = $(assetId+'_thumbnail_data').value.evalJSON();
    var url = thumbnails[size];
    if (editor.valid() && isTabVisible(editor.area())) {
      editor.restoreSelection();
      editor.insertImage(url, link)
    } else if (textarea && isTabVisible(textarea)) {
      var insertText = '\n!' + url + '!';
      if (link)
        insertText += ':' + thumbnails['full'];
      insertText += '\n';
      insertAtCursor(textarea, insertText);
    }
  } catch(e) {}
}

function updateLink(wikiId,action) {
  var editor = new HtmlEditor(wikiId);
  editor.restoreSelection();
  if (action == 'create' || action == 'update') {
    editor.insertAnchor($('link_label').value, $('link_url').value);
  } else if (action == 'clear') {
    editor.clearAnchor();
  }
}

//
// TEXTAREA HELPERS
//

function insertAtCursor(textarea, text) {
  var element = $(textarea);
  if (document.selection) {
    //IE support
    var sel = document.selection.createRange();
    sel.text = text;
  } else if (element.selectionStart || element.selectionStart == '0') {
    //Mozilla/Firefox/Netscape 7+ support
    var startPos = element.selectionStart;
    var endPos   = element.selectionEnd;
    element.value = element.value.substring(0, startPos) + text + element.value.substring(endPos, element.value.length);
    element.setSelectionRange(startPos, endPos+text.length);
    element.scrollTop = startPos
  } else {
    element.value += text;
  }
  element.focus();
}

//
// WIKI EDITOR TABS
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
    textarea.focus();
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
