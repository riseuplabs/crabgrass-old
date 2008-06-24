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
  tabs = [document.getElementsByClassName("tab"),document.getElementsByClassName("tab-link")].flatten();
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

/* I can't get Element.toggle to work with $$().each, because it returns [element,number]
   for each element and not element. */
function mytoggle(element) {
    Element.toggle(element)
}


/* Script for sidebar open-close */
var heads=null;
var open_txt='close all';
var closed_txt='open all';
function toggle_sidenav(obj,from_all)
{
	$(obj).next('div').toggle();
	var new_bg=($(obj).next('div').getStyle('display')=='block')?'/images/ui/carrot-down.jpg':'/images/ui/carrot-right.jpg';
	$(obj).setStyle({backgroundImage:'url('+new_bg+')'});
	if(from_all==undefined)
		manage_txt();
}
function manage_txt()
{
	var ct=0;var open=0;
	heads.each(function(item){ct++;if(item.next('div').getStyle('display')=='block'){open++;}});
	if(ct==open){$('toggle_all').innerHTML=open_txt;}
	if(open==0){$('toggle_all').innerHTML=closed_txt;}
}
function toggle_all()
{
	heads.each(function(item){
		if(($('toggle_all').innerHTML==open_txt && item.next('div').getStyle('display')=='block') || ($('toggle_all').innerHTML==closed_txt && item.next('div').getStyle('display')=='none'))
		{
			toggle_sidenav(item,{});
		}
	});
	manage_txt();
}
Event.observe(window,'load',function(){
	/* make sure the text is correct */
	open_txt=$('toggle_all').innerHTML;
	/* add the handlers to the headers */
	heads=document.getElementsByClassName('sideheadright',$('rightbar'));
	heads.each(function(item){
		Event.observe(item,'click',function(evt){var e=Event.element(evt);toggle_sidenav(e);});
		Event.observe(item,'mouseover',function(evt){var e=Event.element(evt);e.setStyle({cursor:'pointer'})});
		Event.observe(item,'mouseout',function(evt){var e=Event.element(evt);e.setStyle({cursor:''})});
	});
	/* toggle all button */
	Event.observe($('toggle_all'),'click',function(evt){toggle_all();});
})


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

