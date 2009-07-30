function quickRedReference() {
  window.open(
    "/static/greencloth",
    "redRef",
    "height=600,width=750/inv,channelmode=0,dependent=0," +
    "directories=0,fullscreen=0,location=0,menubar=0," +
    "resizable=0,scrollbars=1,status=1,toolbar=0"
  );
  return false;
}

//
// CSS UTILITY
//

function replace_class_name(element, old_class, new_class) {element.removeClassName(old_class); element.addClassName(new_class)}

function setClassVisibility(selector, visibility) {
  $$(selector).each(function(element){
    visibility ? element.show() : element.hide();
  })
}

//
// FORM UTILITY
//

// toggle the visibility of another element based on if
// a checkbox is checked or not.
function checkbox_toggle_visibility(checkbox, element_id) {
  if (checkbox.checked) {$(element_id).show();}
  else {$(element_id).hide();}
}

// toggle all checkboxes of a particular css selected, based on the
// checked status of the checkbox passed in.
function toggle_all_checkboxes(checkbox, selector) {
  $$(selector).each(function(cb) {cb.checked = checkbox.checked})
}

// submits a form, from the onclick of a link.
// use like <a href='' onclick='submit_form(this,"bob")'>bob</a>
// value is optional.
function submit_form(form_element, name, value) {
  e = form_element;
  form = null;
  do {
    if(e.tagName == 'FORM'){form = e; break}
  } while(e = e.parentNode)
  if (form) {
    input = document.createElement("input");
    input.name = name;
    input.type = "hidden";
    input.value = value;
    form.appendChild(input);
    if (form.onsubmit) {
      form.onsubmit(); // for ajax forms.
    } else {
      form.submit();
    }
  }
}

//
// TEXT AREAS
//

function insertAtCursor(text_area_id, text_to_insert) {
  var element = $(text_area_id);
  element.focus();
  if (document.selection) {
    //IE support
    sel = document.selection.createRange();
    sel.text = text_to_insert;
  } else if (element.selectionStart || element.selectionStart == '0') {
    //Mozilla/Firefox/Netscape 7+ support
    var startPos = element.selectionStart;
    var endPos   = element.selectionEnd;
    element.value = element.value.substring(0, startPos) + text_to_insert + element.value.substring(endPos, element.value.length);
    element.setSelectionRange(endPos+text_to_insert.length, endPos+text_to_insert.length);
  } else {
    element.value += text_to_insert;
  }
}

function decorate_wiki_edit_links(ajax_link) {
  $$('.wiki h1 a.anchor, .wiki h2 a.anchor, .wiki h3 a.anchor, .wiki h4 a.achor').each(
    function(elem) {
      var heading_name = elem.href.replace(/^.*#/, '');
      var link = ajax_link.replace(/_change_me_/g, heading_name);
      elem.insert({after:link});
    }
  );
}

function setRows(elem, rows) {
  elem.rows = rows;
  elem.toggleClassName('tall');
}

//
// EVENTS
//

// returns true if the enter key was pressed
function enterPressed(event) {
  if(event.which) { return(event.which == 13); }
  else { return(event.keyCode == 13); }
}

function eventTarget(event) {
  event = event || window.event; // IE doesn't pass event as argument.
  return(event.target || event.srcElement); // IE doesn't use .target
}

//
// POSITION
//

function absolutePosition(obj) {
  var curleft = curtop = 0;
  if (obj.offsetParent) {
    do {
      curleft += obj.offsetLeft;
      curtop += obj.offsetTop;
    } while (obj = obj.offsetParent);
  }
  return [curleft,curtop];
}
function absolutePositionParams(obj) {
  obj_dims = absolutePosition(obj);
  page_dims = document.viewport.getDimensions();
  return 'position=' + obj_dims.join('x') + '&page=' + page_dims.width + 'x' + page_dims.height
}

//
// DYNAMIC TABS
// naming scheme: location.hash => '#most-viewed', tablink.id => 'most_viewed_link', tabcontent.id => 'most_viewed_panel'
//

function evalAttributeOnce(element, attribute) {
  if (element.readAttribute(attribute)) {
    eval(element.readAttribute(attribute));
    element.writeAttribute(attribute, null);
  }
}

function showTab(tabLink, tabContent, hash) {
  tabset = tabLink.parentNode.parentNode
  $$('ul.tabset a').each( function(elem) {
    if (tabset == elem.parentNode.parentNode) {elem.removeClassName('active');}
  })
  $$('.tab_content').each( function(elem) {elem.hide();})
  tabLink.addClassName('active');
  tabContent.show();
  evalAttributeOnce(tabContent, 'onclick');
  tabLink.blur();
  if (hash) {window.location.hash = hash}
  return false;
}

var defaultHash = null;

function showTabByHash() {
  if (hash = (window.location.hash || defaultHash)) {
    hash = hash.replace(/^#/, '').replace(/-/g, '_');
    tabContent = $(hash + '_panel');
    tabLink = $(hash + '_link');
    showTab(tabLink, tabContent)
  }
}

//
// TOP MENUS
//

var DropMenu = Class.create({
  initialize: function(menu_id) {
//    this.show_timeout = null;
//    this.hide_timeout = null;
    this.timeout = null;
    if(!$(menu_id)) return;
    this.trigger = $(menu_id);
    if(!this.trigger) return;
    this.menu = $(menu_id).down('.menu_items');
    if(!this.menu) return;
    this.trigger.observe('mouseover', this.showMenu.bind(this));
    this.trigger.observe('mouseout', this.hideMenu.bind(this));
    //document.observe('mouseover', function(){ this.menu.show()}.bind(this));
  },

  menuIsOpen: function() {
    return($$('.menu_items').detect(function(e){return e.visible()}) != null);
  },

  clearEvents: function(event) {
    event.stop();
    $$('.menu_items').without(this.menu).invoke('hide');
  },

  showMenu: function(event) {
    evalAttributeOnce(this.menu, 'onclick');
    if (this.timeout) window.clearTimeout(this.timeout);
    if (this.menuIsOpen()) {
      this.menu.show();
      this.clearEvents(event);
    } else {
      this.timeout = Element.show.delay(.3,this.menu);
      this.clearEvents(event);
    }
  },

  hideMenu: function(event) {
    this.clearEvents(event);
    if (this.timeout) window.clearTimeout(this.timeout);
    this.timeout = Element.hide.delay(.3, this.menu);
  }

});

document.observe('dom:loaded', function() {
  new DropMenu("menu_me");
  new DropMenu("menu_people");
  new DropMenu("menu_groups");
  new DropMenu("menu_networks");
});

//
// DEAD SIMPLE AJAX HISTORY
// allow location.hash change to trigger a callback event.
//

var onHashChanged = null; // called whenever location.hash changes
var currentHash = '##';
function pollHash() {
  if ( window.location.hash != currentHash ) {
    currentHash = window.location.hash;
    onHashChanged();
  }
}
document.observe("dom:loaded", function() {
  if (onHashChanged) {setInterval("pollHash()", 100)}
});

