/*
 * wiki editing javascript
 * stolen and modified from http://livepipe.net/control/textarea
 */

/**
 * @author Ryan Johnson <http://saucytiger.com/>
 * @copyright 2008 PersonalGrid Corporation <http://personalgrid.com/>
 * @package LivePipe UI
 * @license MIT
 * @url http://livepipe.net/core
 * @require prototype.js
 */

if(typeof(Control) == 'undefined')
	Control = {};

var $proc = function(proc){
	return typeof(proc) == 'function' ? proc : function(){return proc};
};

var $value = function(value){
	return typeof(value) == 'function' ? value() : value;
};

Object.Event = {
	extend: function(object){
		object._objectEventSetup = function(event_name){
			this._observers = this._observers || {};
			this._observers[event_name] = this._observers[event_name] || [];
		};
		object.observe = function(event_name,observer){
			if(typeof(event_name) == 'string' && typeof(observer) != 'undefined'){
				this._objectEventSetup(event_name);
				if(!this._observers[event_name].include(observer))
					this._observers[event_name].push(observer);
			}else
				for(var e in event_name)
					this.observe(e,event_name[e]);
		};
		object.stopObserving = function(event_name,observer){
			this._objectEventSetup(event_name);
			if(event_name && observer)
				this._observers[event_name] = this._observers[event_name].without(observer);
			else if(event_name)
				this._observers[event_name] = [];
			else
				this._observers = {};
		};
		object.observeOnce = function(event_name,outer_observer){
			var inner_observer = function(){
				outer_observer.apply(this,arguments);
				this.stopObserving(event_name,inner_observer);
			}.bind(this);
			this._objectEventSetup(event_name);
			this._observers[event_name].push(inner_observer);
		};
		object.notify = function(event_name){
			this._objectEventSetup(event_name);
			var collected_return_values = [];
			var args = $A(arguments).slice(1);
			try{
				for(var i = 0; i < this._observers[event_name].length; ++i)
					collected_return_values.push(this._observers[event_name][i].apply(this._observers[event_name][i],args) || null);
			}catch(e){
				if(e == $break)
					return false;
				else
					throw e;
			}
			return collected_return_values;
		};
		if(object.prototype){
			object.prototype._objectEventSetup = object._objectEventSetup;
			object.prototype.observe = object.observe;
			object.prototype.stopObserving = object.stopObserving;
			object.prototype.observeOnce = object.observeOnce;
			object.prototype.notify = function(event_name){
				if(object.notify){
					var args = $A(arguments).slice(1);
					args.unshift(this);
					args.unshift(event_name);
					object.notify.apply(object,args);
				}
				this._objectEventSetup(event_name);
				var args = $A(arguments).slice(1);
				var collected_return_values = [];
				try{
					if(this.options && this.options[event_name] && typeof(this.options[event_name]) == 'function')
						collected_return_values.push(this.options[event_name].apply(this,args) || null);
					for(var i = 0; i < this._observers[event_name].length; ++i)
						collected_return_values.push(this._observers[event_name][i].apply(this._observers[event_name][i],args) || null);
				}catch(e){
					if(e == $break)
						return false;
					else
						throw e;
				}
				return collected_return_values;
			};
		}
	}
};

/* Begin Core Extensions */

//Element.observeOnce
Element.addMethods({
	observeOnce: function(element,event_name,outer_callback){
		var inner_callback = function(){
			outer_callback.apply(this,arguments);
			Element.stopObserving(element,event_name,inner_callback);
		};
		Element.observe(element,event_name,inner_callback);
	}
});

//mouseenter, mouseleave
//from http://dev.rubyonrails.org/attachment/ticket/8354/event_mouseenter_106rc1.patch
Object.extend(Event, (function() {
	var cache = Event.cache;

	function getEventID(element) {
		if (element._prototypeEventID) return element._prototypeEventID[0];
		arguments.callee.id = arguments.callee.id || 1;
		return element._prototypeEventID = [++arguments.callee.id];
	}

	function getDOMEventName(eventName) {
		if (eventName && eventName.include(':')) return "dataavailable";
		//begin extension
		if(!Prototype.Browser.IE){
			eventName = {
				mouseenter: 'mouseover',
				mouseleave: 'mouseout'
			}[eventName] || eventName;
		}
		//end extension
		return eventName;
	}

	function getCacheForID(id) {
		return cache[id] = cache[id] || { };
	}

	function getWrappersForEventName(id, eventName) {
		var c = getCacheForID(id);
		return c[eventName] = c[eventName] || [];
	}

	function createWrapper(element, eventName, handler) {
		var id = getEventID(element);
		var c = getWrappersForEventName(id, eventName);
		if (c.pluck("handler").include(handler)) return false;

		var wrapper = function(event) {
			if (!Event || !Event.extend ||
				(event.eventName && event.eventName != eventName))
					return false;

			Event.extend(event);
			handler.call(element, event);
		};

		//begin extension
		if(!(Prototype.Browser.IE) && ['mouseenter','mouseleave'].include(eventName)){
			wrapper = wrapper.wrap(function(proceed,event) {
				var rel = event.relatedTarget;
				var cur = event.currentTarget;
				if(rel && rel.nodeType == Node.TEXT_NODE)
					rel = rel.parentNode;
				if(rel && rel != cur && !rel.descendantOf(cur))
					return proceed(event);
			});
		}
		//end extension

		wrapper.handler = handler;
		c.push(wrapper);
		return wrapper;
	}

	function findWrapper(id, eventName, handler) {
		var c = getWrappersForEventName(id, eventName);
		return c.find(function(wrapper) { return wrapper.handler == handler });
	}

	function destroyWrapper(id, eventName, handler) {
		var c = getCacheForID(id);
		if (!c[eventName]) return false;
		c[eventName] = c[eventName].without(findWrapper(id, eventName, handler));
	}

	function destroyCache() {
		for (var id in cache)
			for (var eventName in cache[id])
				cache[id][eventName] = null;
	}

	if (window.attachEvent) {
		window.attachEvent("onunload", destroyCache);
	}

	return {
		observe: function(element, eventName, handler) {
			element = $(element);
			var name = getDOMEventName(eventName);

			var wrapper = createWrapper(element, eventName, handler);
			if (!wrapper) return element;

			if (element.addEventListener) {
				element.addEventListener(name, wrapper, false);
			} else {
				element.attachEvent("on" + name, wrapper);
			}

			return element;
		},

		stopObserving: function(element, eventName, handler) {
			element = $(element);
			var id = getEventID(element), name = getDOMEventName(eventName);

			if (!handler && eventName) {
				getWrappersForEventName(id, eventName).each(function(wrapper) {
					element.stopObserving(eventName, wrapper.handler);
				});
				return element;

			} else if (!eventName) {
				Object.keys(getCacheForID(id)).each(function(eventName) {
					element.stopObserving(eventName);
				});
				return element;
			}

			var wrapper = findWrapper(id, eventName, handler);
			if (!wrapper) return element;

			if (element.removeEventListener) {
				element.removeEventListener(name, wrapper, false);
			} else {
				element.detachEvent("on" + name, wrapper);
			}

			destroyWrapper(id, eventName, handler);

			return element;
		},

		fire: function(element, eventName, memo) {
			element = $(element);
			if (element == document && document.createEvent && !element.dispatchEvent)
				element = document.documentElement;

			var event;
			if (document.createEvent) {
				event = document.createEvent("HTMLEvents");
				event.initEvent("dataavailable", true, true);
			} else {
				event = document.createEventObject();
				event.eventType = "ondataavailable";
			}

			event.eventName = eventName;
			event.memo = memo || { };

			if (document.createEvent) {
				element.dispatchEvent(event);
			} else {
				element.fireEvent(event.eventType, event);
			}

			return Event.extend(event);
		}
	};
})());

Object.extend(Event, Event.Methods);

Element.addMethods({
	fire:			Event.fire,
	observe:		Event.observe,
	stopObserving:	Event.stopObserving
});

Object.extend(document, {
	fire:			Element.Methods.fire.methodize(),
	observe:		Element.Methods.observe.methodize(),
	stopObserving:	Element.Methods.stopObserving.methodize()
});

//mouse:wheel
(function(){
	function wheel(event){
		var delta;
		// normalize the delta
		if(event.wheelDelta) // IE & Opera
			delta = event.wheelDelta / 120;
		else if (event.detail) // W3C
			delta =- event.detail / 3;
		if(!delta)
			return;
		var custom_event = event.element().fire('mouse:wheel',{
			delta: delta
		});
		if(custom_event.stopped){
			event.stop();
			return false;
		}
	}
	document.observe('mousewheel',wheel);
	document.observe('DOMMouseScroll',wheel);
})();

/* End Core Extensions */

//from PrototypeUI
var IframeShim = Class.create({
	initialize: function() {
		this.element = new Element('iframe',{
			style: 'position:absolute;filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);display:none',
			src: 'javascript:void(0);',
			frameborder: 0
		});
		$(document.body).insert(this.element);
	},
	hide: function() {
		this.element.hide();
		return this;
	},
	show: function() {
		this.element.show();
		return this;
	},
	positionUnder: function(element) {
		var element = $(element);
		var offset = element.cumulativeOffset();
		var dimensions = element.getDimensions();
		this.element.setStyle({
			left: offset[0] + 'px',
			top: offset[1] + 'px',
			width: dimensions.width + 'px',
			height: dimensions.height + 'px',
			zIndex: element.getStyle('zIndex') - 1
		}).show();
		return this;
	},
	setBounds: function(bounds) {
		for(prop in bounds)
			bounds[prop] += 'px';
		this.element.setStyle(bounds);
		return this;
	},
	destroy: function() {
		if(this.element)
			this.element.remove();
		return this;
	}
});

/**
 * @author Ryan Johnson <http://saucytiger.com/>
 * @copyright 2008 PersonalGrid Corporation <http://personalgrid.com/>
 * @package LivePipe UI
 * @license MIT
 * @url http://livepipe.net/control/textarea
 * @require prototype.js, livepipe.js
 */

if(typeof(Prototype) == "undefined")
	throw "Control.TextArea requires Prototype to be loaded.";
if(typeof(Object.Event) == "undefined")
	throw "Control.TextArea requires Object.Event to be loaded.";

Control.TextArea = Class.create({
	initialize: function(textarea){
		this.onChangeTimeout = false;
		this.element = $(textarea);
		$(this.element).observe('keyup',this.doOnChange.bindAsEventListener(this));
		$(this.element).observe('paste',this.doOnChange.bindAsEventListener(this));
		$(this.element).observe('input',this.doOnChange.bindAsEventListener(this));
		if(!!document.selection){
			$(this.element).observe('mouseup',this.saveRange.bindAsEventListener(this));
			$(this.element).observe('keyup',this.saveRange.bindAsEventListener(this));
		}
	},
	doOnChange: function(event){
		if(this.onChangeTimeout)
			window.clearTimeout(this.onChangeTimeout);
		this.onChangeTimeout = window.setTimeout(function(){
			this.notify('change',this.getValue());
		}.bind(this),Control.TextArea.onChangeTimeoutLength);
	},
	saveRange: function(){
		this.range = document.selection.createRange();
	},
	getValue: function(){
		return this.element.value;
	},
	getSelection: function(){
		if(!!document.selection)
			return document.selection.createRange().text;
		else if(!!this.element.setSelectionRange)
			return this.element.value.substring(this.element.selectionStart,this.element.selectionEnd);
		else
			return false;
	},
	replaceSelection: function(text){
		var scroll_top = this.element.scrollTop;
		if(!!document.selection){
			this.element.focus();
			var range = (this.range) ? this.range : document.selection.createRange();
			range.text = text;
			range.select();
		}else if(!!this.element.setSelectionRange){
			var selection_start = this.element.selectionStart;
			this.element.value = this.element.value.substring(0,selection_start) + text + this.element.value.substring(this.element.selectionEnd);
			this.element.setSelectionRange(selection_start + text.length,selection_start + text.length);
		}
		this.doOnChange();
		this.element.focus();
		this.element.scrollTop = scroll_top;
	},
	wrapSelection: function(before,after){
		this.replaceSelection(before + this.getSelection() + after);
	},
	insertBeforeSelection: function(text){
		this.replaceSelection(text + this.getSelection());
	},
	insertAfterSelection: function(text){
		this.replaceSelection(this.getSelection() + text);
	},
	collectFromEachSelectedLine: function(callback,before,after){
		this.replaceSelection((before || '') + $A(this.getSelection().split("\n")).collect(callback).join("\n") + (after || ''));
	},
	insertBeforeEachSelectedLine: function(text,before,after){
		this.collectFromEachSelectedLine(function(line){
		},before,after);
	}
});
Object.extend(Control.TextArea,{
	onChangeTimeoutLength: 500
});
Object.Event.extend(Control.TextArea);

Control.TextArea.ToolBar = Class.create(	{
	initialize: function(textarea,toolbar){
		this.textarea = textarea;
		if(toolbar)
			this.container = $(toolbar);
		else{
			this.container = $(document.createElement('ul'));
			this.textarea.element.parentNode.insertBefore(this.container,this.textarea.element);
		}
	},
	attachButton: function(node,callback){
		node.onclick = function(){return false;}
		$(node).observe('click',callback.bindAsEventListener(this.textarea));
	},
	addButton: function(link_text,callback,attrs){
		var li = document.createElement('li');
		var a = document.createElement('a');
		a.href = '#';
    a.title = link_text; // crabgrass addition
    // crabgrass addition
    if(attrs['class']) {
      Element.extend(a).addClassName(attrs['class']);
      attrs['class'] = null;
    }
		this.attachButton(a,callback);
		li.appendChild(a);
		Object.extend(a,attrs || {});
		if(link_text){
			var span = document.createElement('span');
			span.innerHTML = link_text;
			a.appendChild(span);
		}
		this.container.appendChild(li);
	}
});

// --- ACTUAL CUSTOM CODE BEGINS HERE ---

// add the toolbar controlling wiki body
// each id used by the toolbar has a prefix, so that multiple toolbars
// can be used on the same page
function wikiEditAddToolbar(wiki_body_id, toolbar_id, button_id_suffix, image_popup_func)
{
  //setup
  var textarea = new Control.TextArea(wiki_body_id);
  var toolbar = new Control.TextArea.ToolBar(textarea);

  toolbar.container.addClassName('markdown_toolbar'); //for css styles
  toolbar.container.id = toolbar_id; //for css styles

  //buttons
  toolbar.addButton('Emphasis',function(){
          this.wrapSelection('_','_');
  },{
          'class': 'markdown_italics_button',
          id: 'markdown_italics_button-' + button_id_suffix
  });

  toolbar.addButton('Strong emphasis',function(){
          this.wrapSelection('*','*');
  },{
          'class': 'markdown_bold_button',
          id: 'markdown_bold_button-' + button_id_suffix
  });

  toolbar.addButton('Link',function(){
          var selection = this.getSelection();
          var response = prompt('Enter Link Target','');
          if(response == null)
                  return;
          this.replaceSelection('[' + (selection == '' ? 'Link Text' : selection) + '->' + (response == '' ? 'http://link_url/' : response) + ']');
  },{
          'class': 'markdown_link_button',
          id: 'markdown_link_button-' + button_id_suffix
  });

  toolbar.addButton('Image',function(){
          // img_button_clicked();
          image_popup_func();
  },{
          'class': 'markdown_image_button',
          id: 'markdown_image_button-' + button_id_suffix
  });

  toolbar.addButton('Heading',function(){
          var selection = this.getSelection();
          if(selection == '')
                  selection = 'Heading';
          this.replaceSelection("\nh1. " + selection + "\n");
  },{
          'class': 'markdown_heading_button',
          id: 'markdown_heading_button-' + button_id_suffix
  });

  toolbar.addButton('Unordered List',function(event){
          this.collectFromEachSelectedLine(function(line){
                  return event.shiftKey ? (line.match(/^\*{2,}/) ? line.replace(/^\*/,'') : line.replace(/^\*\s/,'')) : (line.match(/\*+\s/) ? '*' : '* ') + line;
          });
  },{
          'class': 'markdown_unordered_list_button',
          id: 'markdown_unordered_list_button-' + button_id_suffix
  });

  toolbar.addButton('Ordered List',function(event){
          var i = 0;
          this.collectFromEachSelectedLine(function(line){
                  return event.shiftKey ? (line.match(/^\#{2,}/) ? line.replace(/^\#/,'') : line.replace(/^\#\s/,'')) : (line.match(/\#+\s/) ? '#' : '# ') + line;
          });
  },{
          'class': 'markdown_ordered_list_button',
          id: 'markdown_ordered_list_button-' + button_id_suffix
  });

  toolbar.addButton('Block Quote',function(event){
          this.collectFromEachSelectedLine(function(line){
                  return event.shiftKey ? line.replace(/^\> /,'') : '> ' + line;
          });
  },{
          'class': 'markdown_quote_button',
          id: 'markdown_quote_button-' + button_id_suffix
  });

  toolbar.addButton('Code Block',function(event){
          this.wrapSelection('<code>', '</code>');
  },{
          'class': 'markdown_code_button',
          id: 'markdown_code_button-' + button_id_suffix
  });

  toolbar.addButton('Help',quickRedReference,{
          'class': 'markdown_help_button',
          id: 'markdown_help_button-' + button_id_suffix
  });
}

//document.observe('dom:loaded', function() {
  //
//});
