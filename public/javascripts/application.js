// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function quickRedReference() {
  window.open( 
    "/static/greencloth",
    "redRef",
    "height=600,width=750/inv,channelmode=0,dependent=0," +
    "directories=0,fullscreen=0,location=0,menubar=0," +
    "resizable=0,scrollbars=1,status=1,toolbar=0"
  );
}

function show_tab(tab_link, tab_content) {
  tabs = document.getElementsByClassName("tab");
  for(i = 0; i < tabs.length; i++) {
    Element.removeClassName(tabs[i], 'selected');
  }
  tabs = document.getElementsByClassName("tab-link");
  for(i = 0; i < tabs.length; i++) {
    Element.removeClassName(tabs[i], 'selected');
  }
  tabs = document.getElementsByClassName("tab-content");
  for(i = 0; i < tabs.length; i++) {
    Element.hide(tabs[i]);
  }
  Element.addClassName(tab_link, 'selected');
  Element.addClassName(tab_link.ancestors().first(), 'selected');
  Element.show(tab_content);
  tab_link.blur();
  return false;
}

// submits a form, from the onclick of a link. 
// use like <a href='' onclick='submit_form(this,"bob")'>bob</a>
function submit_form(link, name, value) {
  form = link.ancestors().find(function(e) {
    return e.nodeName == 'FORM';
  })
  e = document.createElement("input");
  e.name = name;
  e.type = "hidden";
  e.value = value;
  form.appendChild(e);
  if (form.onsubmit) {
    form.onsubmit(); // for ajax forms.
  } else {
    form.submit();
  }
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

/** menu navigation **/

var SubMenu = Class.create({
  initialize: function(li) {
    if(!$(li)) return;
    this.trigger = $(li).down('em');
    if(!this.trigger) return;
    this.menu = $(li).down('ul');
    this.trigger.observe('click', this.respondToClick.bind(this));
    document.observe('click', function(){ this.menu.hide()}.bind(this));
  },
  
  respondToClick: function(event) {
    event.stop();
    $$('ul.submenu').without(this.menu).invoke('hide');
    this.menu.toggle()
  }
});


document.observe('dom:loaded', function() {
  new SubMenu("menu-me");
  new SubMenu("menu-people");
});



/** finding position **/

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
