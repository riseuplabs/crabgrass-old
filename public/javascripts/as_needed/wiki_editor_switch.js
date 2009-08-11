//
// Wysiwyg / GreenCloth Wiki Editors
//
function updateEditor(response, editor, id) {
  if(response.status != 200)
    return false;

  /* Update editors as needed */
  if(response.responseJSON.wysiwyg) {
    content = getBackNewLines(response.responseJSON.wysiwyg);
    nicEditors.findEditor("wysiwyg_" + id).setContent(content);
  }

  if(response.responseJSON.greencloth) {
    content = getBackNewLines(response.responseJSON.greencloth);
    $(id).setValue(content);
  }  

  if(response.responseJSON.preview) {
    content = getBackNewLines(response.responseJSON.preview);
    $("preview_" + id).innerHTML = content;
  }  

  /* Switch to correspondant tab */
  if(editor == 'greencloth') {
    showTab($('link-tab-greencloth'), $('tab-edit-greencloth'));
  } 
  else if(editor == 'wysiwyg') {
    showTab($('link-tab-wysiwyg'), $('tab-edit-wysiwyg'));
  }
  else if(editor == 'preview') {
    showTab($('link-tab-preview'), $('tab-edit-preview'));
  }
}

function getBackNewLines(str) {
  return str.replace(/__NEW_LINE__/g, '\n').replace(/__TAB_CHAR__/g, '\t');
}

function getActiveTabLink() {
  return $$('li.tab a.active')[0];
}

function isTabSelected(link) {
  if(link.id == getActiveTabLink().id)
    return true;
  else
    return false;
}

function getCurrentEditorContents(wiki_body_id) {
  var tab = getActiveTabLink(); 

  switch(tab.id) {
    case 'link-tab-wysiwyg':
      return "wiki[body_wysiwyg]=" + nicEditors.findEditor("wysiwyg_" + wiki_body_id).getContent();
      break;
    case 'link-tab-greencloth':
      return Form.Element.serialize(wiki_body_id);
      break;
  }
}
