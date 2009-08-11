//
// Wysiwyg / GreenCloth Wiki Editors
//

function updateEditor(response, tab, id) {
  if(response.status != 200)
    return false;

  var content  = "";
  var editor   = nicEditors.findEditor("wiki_editor-" + id);
  var textarea = $("wiki_body-" + id);
  var preview  = $("wiki_preview-" + id);

  if (response.responseJSON.wysiwyg) {
    content = getBackNewLines(response.responseJSON.wysiwyg);
    editor.setContent(content);
  }
  if (response.responseJSON.greencloth) {
    content = getBackNewLines(response.responseJSON.greencloth);
    textarea.setValue(content);
  }
  if (response.responseJSON.preview) {
    content = getBackNewLines(response.responseJSON.preview);
    preview.update(content);
  }

  if (tab == 'greencloth') {
    showTab($('link-tab-greencloth'), $('tab-edit-greencloth'));
  }
  else if (tab == 'wysiwyg') {
    showTab($('link-tab-wysiwyg'), $('tab-edit-wysiwyg'));
  }
  else if (tab == 'preview') {
    showTab($('link-tab-preview'), $('tab-edit-preview'));
  }
}

function getBackNewLines(str) {
  return str.replace(/__NEW_LINE__/g, '\n').replace(/__TAB_CHAR__/g, '\t');
}

function getActiveTabLink() {
  return $$('ul.simple_tabset a.active')[0];
}

function isTabSelected(link) {
  if(link.id == getActiveTabLink().id)
    return true;
  else
    return false;
}

function getCurrentEditorContents(wiki_id) {
  var tab = getActiveTabLink();

  switch(tab.id) {
    case 'link-tab-wysiwyg':
      return $H({'wiki[body_wysiwyg]': nicEditors.findEditor("wiki_editor-" + wiki_id).getContent()}).toQueryString();
      break;
    case 'link-tab-greencloth':
      return $('wiki_body-'+wiki_id).serialize();
      break;
  }
}


//
// A generic nicedit button that calls a js function.
//

var nicFunctionButton = nicEditorButton.extend({
  mouseClick : function() {
    this.ne.options[this.options.function]();
  }
});

//
// nicEdit plugin for crabgrass image popup
//

var nicCgImageOptions = {
  buttons: {
    image: {name: 'Add Image', type: 'nicFunctionButton', function: 'onImgButtonClick'}
  }
};
nicEditors.registerPlugin(nicPlugin,nicCgImageOptions);

