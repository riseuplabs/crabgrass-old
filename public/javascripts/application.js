
//
// CRABGRASS HELPERS
//

// shows the 'notice' message (ie errors and success)
// if there is a popup currently open, then the messages shows up there.
// set msg to "" in order to hide it.
function showNoticeMessage(msg) {
  Autocomplete.hideAll();
  if ($('modal_message')) {
    $('modal_message').update(msg);
  } else if ($('message')) {
    $('message').update(msg);
    if (msg)
      window.location.hash = "message";
  }
}

// opens the greencloth editing reference.
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

// Toggle the visibility of another element based on if a checkbox is checked or
// not. Additionally, sets the focus to the first input or textarea that is visible.
function checkboxToggle(checkbox, element) {
  if (checkbox.checked) {
    $(element).show();
    var focusElm = $(element).select('input[type=text]), textarea').first();
    var isVisible = focusElm.visible() && !focusElm.ancestors().find(function(e){return !e.visible()});
    if (focusElm && isVisible) {
      focusElm.focus();
    }
  } else {
    $(element).hide();
  }
}

// Toggle the visibility of another element using a link with an
// expanding/contracting arrow.
function linkToggle(link, element) {
  if (link) {
    link = Element.extend(link);
    link.toggleClassName('right_16');
    link.toggleClassName('sort_down_16');
    $(element).toggle();
  }
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
  var e = form_element;
  var form = null;
  do {
    if(e.tagName == 'FORM'){form = e; break}
  } while(e = e.parentNode)
  if (form) {
    var input = document.createElement("input");
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
  event = event || window.event;            // IE doesn't pass event as argument.
  return(event.target || event.srcElement); // IE doesn't use .target
}

//
// POSITION
//

//
// this should be replaced with element.cumulativeOffset()
//
function absolutePosition(obj) {
  var curleft = 0;
  var curtop = 0;
  if (obj.offsetParent) {
    do {
      curleft += obj.offsetLeft;
      curtop += obj.offsetTop;
    } while (obj = obj.offsetParent);
  }
  return [curleft,curtop];
}
function absolutePositionParams(obj) {
  var obj_dims = absolutePosition(obj);
  var page_dims = document.viewport.getDimensions();
  return 'position=' + obj_dims.join('x') + '&page=' + page_dims.width + 'x' + page_dims.height
}

//
// DYNAMIC TABS
// naming scheme: location.hash => '#most-viewed', tablink.id => 'most_viewed_link', tabcontent.id => 'most_viewed_panel'
//

function evalAttributeOnce(element, attribute) {
  if (element.readAttribute(attribute)) {
    eval(element.readAttribute(attribute));
    element.writeAttribute(attribute, "");
  }
}

function showTab(tabLink, tabContent, hash) {
  tabLink = $(tabLink);
  tabContent = $(tabContent);
  var tabset = tabLink.up('.tabset');
  if (tabset) {
    tabset.select('a').invoke('removeClassName', 'active');
    $$('.tab_content').invoke('hide');
    tabLink.addClassName('active');
    tabContent.show();
    evalAttributeOnce(tabContent, 'onclick');
    tabLink.blur();
    if (hash) {window.location.hash = hash}
  }
  return false;
}

var defaultHash = null;

function showTabByHash() {
  var hash = window.location.hash || defaultHash;
  if (hash) {
    hash = hash.replace(/^#/, '').replace(/-/g, '_');
    showTab(hash+'_link', hash+'_panel')
  }
}

// returns true if the element is in a tab content area that is visible.
function isTabVisible(elem) {
  return $(elem).ancestors().find(function(e){return e.hasClassName('tab_content') && e.visible();})
}

//
// TOP MENUS
//

var DropMenu = Class.create({
  initialize: function(menu_id) {
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

//
// COMMON MODAL DIALOGS
//

function loginDialog(txt,options) {
  var form = '' +
  '<form class="login_dialog" method="post" action="/account/login">' +
  '  <input type="hidden" value="#{token}" name="authenticity_token" id="redirect"/>' +
  '  <input type="hidden" value="#{redirect}" name="redirect" id="redirect"/>' +
  '  <label>#{username}</label><input type="text" name="login" id="login" tabindex="1"/>' +
  '  <label>#{password}</label><input type="password" name="password" id="password" tabindex="2"/>' +
  '  <input type="submit" value="#{login}" tabindex="3"/>' +
  '  <span class="small">'
  if (options['may_signup'])
     form += '<a href="/account/signup">#{create_account}</a> | '
  form += '<a href="/account/forgot_password">#{forgot_password}</a></span>' +
  '</form>'
  form = form.interpolate(txt);
  Modalbox.show(form, {title:txt.login, width:350});
}
