// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function showtab(tab) {
  tabs = document.getElementsByClassName("tab-link");
  for(i = 0; i < tabs.length; i++) {
    Element.removeClassName(tabs[i].id, 'selected');
  }
  tabs = document.getElementsByClassName("tab-content");
  for(i = 0; i < tabs.length; i++) {
    Element.hide(tabs[i].id);
  }
  Element.addClassName(tab.id, 'selected');
  Element.show(tab.id+"-content");
  tab.blur();
  return false;
}

function submit_form(form_id, value) {
  f = $(form_id);
  e = document.createElement("input");
  e.name = "commit";
  e.type = "hidden";
  e.value = value;
  f.appendChild(e);
  f.submit();
}

function toggleLink(link, text) {
  if ( link.innerHTML != text )  {
    link.oldInnerHTML = link.innerHTML;
    link.innerHTML = text;    
  } else {
    link.innerHTML = link.oldInnerHTML;
  }
  link.blur();
}

/* I can't get Element.toggle to work with $$().each, because it returns [element,number]
   for each element and not element. */
function mytoggle(element) {
    Element.toggle(element)
}

/* stuff from beast */

/* 

var TopicForm = {
  editNewTitle: function(txtField) {
    $('new_topic').innerHTML = (txtField.value.length > 5) ? txtField.value : 'New Topic';
  }
}

var EditForm = {
  // show the form
  init: function(postId) {
    $('edit-post-' + postId + '_spinner').show();
    this.clearReplyId();
  },

  // sets the current post id we're editing
  setReplyId: function(postId) {
    $('edit').setAttribute('post_id', postId.toString());
    $('posts-' + postId + '-row').addClassName('editing');
    if($('reply')) $('reply').hide();
  },
  
  // clears the current post id
  clearReplyId: function() {
    var currentId = this.currentReplyId()
    if(!currentId || currentId == '') return;

    var row = $('posts-' + currentId + '-row');
    if(row) row.removeClassName('editing');
    $('edit').setAttribute('post_id', '');
  },
  
  // gets the current post id we're editing
  currentReplyId: function() {
    return $('edit').getAttribute('post_id');
  },
  
  // checks whether we're editing this post already
  isEditing: function(postId) {
    if (this.currentReplyId() == postId.toString())
    {
      $('edit').show();
      $('edit_post_body').focus();
      return true;
    }
    return false;
  },

  // close reply, clear current reply id
  cancel: function() {
    this.clearReplyId();
    $('edit').hide()
  }
}

var ReplyForm = {
  // yes, i use setTimeout for a reason
  init: function() {
    EditForm.cancel();
    $('reply').toggle();
    $('post_body').focus();
    // for Safari which is sometime weird
//    setTimeout('$(\"post_body\").focus();',50);
  }
}

Event.addBehavior({
  '#search,#monitor_submit': function() { this.hide(); }
})

*/
