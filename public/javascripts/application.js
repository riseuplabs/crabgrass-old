
//
// CRABGRASS HELPERS
//

// shows the 'notice' message (ie errors and success)
// if there is a popup currently open, then the messages shows up there.
// set msg to "" in order to hide it.
function showNoticeMessage(msg) {
  Autocomplete.hideAll();
  if ($('modal_message') && !$('modal_message').ancestors().detect(function(e){return !e.visible()})) {
    $('modal_message').update(msg);
  } else if ($('flash-message')) {
    $('flash-message').update(msg);
    if (msg)
      window.location.hash = "flash-message";
  }
  $$('.spin').invoke('hide');
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

function replaceClassName(element, old_class, new_class) {element.removeClassName(old_class); element.addClassName(new_class)}

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

// toggle all checkboxes of a particular css selector, based on the
// checked status of the checkbox passed in.
function toggleAllCheckboxesToMatch(checkbox, selector) {
  $$(selector).each(function(cb) {cb.checked = checkbox.checked});
}

// toggle all checkboxes of a particular css selector to checked boolean parameter
function toggleAllCheckboxes(checked, selector) {
  $$(selector).each(function(cb) {cb.checked = checked});
}

// submits a form, from the onclick of a link.
// use like <a href='' onclick='submitForm(this,"bob")'>bob</a>
// value is optional.
function submitForm(form_element, name, value) {
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

// submit a form which updates a nested resource where the parent resource can be selected by the user
// since the parent resource is part of the form action path, the form action attribute has to be dynamically updated
//
// resource_url_template looks like /message/__ID__/posts
// resource_id_field is the DOM id for the input element which has the value for the resource id (the __ID__ value)
// (for example resource_id_field with DOM id 'user_name' has value 'gerrard'. 'gerrard' is the resource id)
// if ignore_default_value is true, then form will not get submited unless resource_id_field was changed by the user
// from the time the page was loaded
// dont_submit_default_value is useful for putting help messages into the field. if the user does not edit the field
// the help message should not be submitted as the resource id
function submitNestedResourceForm(resource_id_field, resource_url_template, dont_submit_default_value) {
  var input = $(resource_id_field);
  // we can submit the default value
  // or the value has changed and isn't blank
  if(dont_submit_default_value == false || (input.value != '' && input.value != input.defaultValue)) {
    var form = input.form;

    var resource_id = input.value;
    form.action = resource_url_template.gsub('__ID__', resource_id);
    form.submit();
  }
}


function setRows(elem, rows) {
  elem.rows = rows;
  elem.toggleClassName('tall');
}

// starts watching the textarea
// when window.onbeforeunload event happens it will ask the user if they want to leave the unsaved form
// everything that matches savingSelectors will permenantly disable the confirm message when clicked
// this a way to exclude "Save" and "Cancel" buttons from raising the "Do you want to discard this?" dialog
function confirmDiscardingTextArea(textAreaId, discardingMessage, savingSelectors) {
  var confirmActive = true;

  // setup confirmation
  // Event.observe(window, 'beforeunload', function(ev) {
  //   if(confirmActive) {
  //     ev.returnValue = discardingMessage;
  //   }
  // })

  window.onbeforeunload = function(ev) {
    if(confirmActive) {
      return discardingMessage;
    }
  };

  // toggle off the confirmation when saving or explicitly discarding the text area (clicking 'cancel' for example)
  savingSelectors.each(function(savingSelector) {
    var savingElements = $$(savingSelector);
    savingElements.each(function(savingElement) {
      savingElement.observe('click', function() {
        // user clicked 'save', 'cancel' or something similar
        // we should no longer display confirmation when leaving page
        confirmActive = false;
      })
    });
  });
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

function evalOnclickOnce(element) {
  if(element.onclick) {
    element.onclick.call();
    element.onclick = "";
  }

  //if (element.readAttribute(attribute)) {
  //  eval(element.readAttribute(attribute));
  //  element[attribute] = "";
  //}
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
    evalOnclickOnce(tabContent);
    tabLink.blur();
    if (hash) {
      window.location.hash = hash;
    }
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
    if(!$(menu_id)) return;
    this.trigger = $(menu_id);
    this.menu = $(menu_id).down('.menu_items');
    this.timeout = null;
    if(!this.trigger) return;
    if(!this.menu) return;
    this.trigger.observe('mouseover', this.showMenuEvent.bind(this));
    this.trigger.observe('mouseout', this.hideMenuEvent.bind(this));
    DropMenu.instances.push(this);
  },

  menuIsOpen: function() {
    return($$('.menu_items').detect(function(e){return e.visible()}) != null);
  },

  clearEvents: function(event) {
    if (this.timeout) window.clearTimeout(this.timeout);
    event.stop();
  },

  showMenuEvent: function(event) {
    evalOnclickOnce(this.menu);
    this.clearEvents(event);
    if (this.menuIsOpen()) {
      DropMenu.instances.invoke('hideMenu');
      this.showMenu();
    } else {
      this.timeout = this.showMenu.bind(this).delay(0.3);
    }
  },

  hideMenuEvent: function(event) {
    this.clearEvents(event);
    this.timeout = this.hideMenu.bind(this).delay(0.3);
  },

  showMenu: function() {
    this.menu.show();
    this.trigger.addClassName('menu_visible');
  },

  hideMenu: function() {
    this.menu.hide();
    this.trigger.removeClassName('menu_visible');
  }

});
DropMenu.instances = [];

//var statuspostCounter = Class.create({
//  initialize: function(id) {
//    if (!$(id)) return;
//    this.trigger = $(id);
//    this.textarea = $(id);
//    this.trigger.observe("keydown", this.textLimit.bind(this));
//    this.trigger.observe("keyup", this.textLimit.bind(this));
//  },
//  textLimit: function(event) {
//    if (this.textarea.value.length > 140) {
//       this.textarea.value = this.textarea.value.substring(0, 140);
//    }
//  }
//});

//var DropSocial = Class.create({
//  initialize: function() {
//    id = "show-social"
//    if(!$(id)) return;
//    this.trigger = $(id);
//    if(!this.trigger) return;
//    this.container = $('social-activities-dropdown');
//    if (!this.container) return;
//    this.activities = $('social_activities_list');
//    if(!this.activities) return;
//    this.trigger.observe('click', this.toggleActivities.bind(this));
//    document.observe('click', this.hideActivities.bind(this));
//  },
//  IsOpen: function() {
//    return this.container.visible();
//  },
//  toggleActivities: function(event) {
//    if (this.IsOpen()) {
//      this.container.hide();
//      this.clearEvents(event);
//    } else {
//      this.container.show();
//      event.stopPropogation();
//      this.clearEvents(event);
//    }
//  },
//  hideActivities: function(event) {
//    element = Event.findElement(event);
//    elementUp = Event.findElement(event, 'div');
//    if ((element != this.trigger) && (elementUp != this.container)) {
//      if (!this.IsOpen()) return;
//      this.container.hide();
//    }
//  }
//})

//var LoadSocial = Class.create({
//  initialize: function() {
//    this.doRequest();
//    new PeriodicalExecuter(this.doRequest, 120);
//  },
//  doRequest: function() {
//    if ($('social-activities-dropdown').visible()) return;
//    new Ajax.Request('/me/social-activities', {
//      method: 'GET',
//      parameters: {count: 1}
//    });
//  }
//})

document.observe('dom:loaded', function() {
  $$(".drop_menu").each(function(element){
    new DropMenu(element.id);
  })
  // new statuspostCounter("say_text");
  // new LoadSocial();
  // new DropSocial();
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
