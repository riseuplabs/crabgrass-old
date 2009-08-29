/*

ModalBox - The pop-up window thingie with AJAX, based on prototype and script.aculo.us.

This code has been forked for crabgrass and heavily modified.

Original Code:

	Copyright Andrey Okonetchnikov (andrej.okonetschnikow@gmail.com), 2006-2007
	All rights reserved.

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

Modalbox event listeners:

	* beforeLoad — fires right before loading contents into the ModalBox. If the callback function returns false, content loading will skipped. This can be used for redirecting user to another MB-page for authorization purposes for example.
	* afterLoad — fires after loading content into the ModalBox (i.e. after showing or updating existing window).
	* beforeHide — fires right before removing elements from the DOM. Might be useful to get form values before hiding modalbox.
	* afterHide — fires after hiding ModalBox from the screen.
	* afterResize — fires after calling resize method.
	* onShow — fires on first appearing of ModalBox before the contents are being loaded.
	* onUpdate — fires on updating the content of ModalBox (on call of Modalbox.show method from active ModalBox instance).

Ajax request event listeners:

	* onComplete -- called when ajax request finishes
	* onLoading  -- called when ajax request starts loading
	* onSuccess  -- called when ajax request returns success

*/

Prototype.Browser.IE6 = Prototype.Browser.IE &&
	parseInt(navigator.userAgent.substring(navigator.userAgent.indexOf("MSIE")+5))==6;
Prototype.Browser.IE7 = Prototype.Browser.IE && !Prototype.Browser.IE6;

if (!window.Modalbox)
	var Modalbox = new Object();

Modalbox.Methods = {
	overrideAlert: true, // Override standard browser alert message with ModalBox
	focusableElements: new Array,
	priorContent: new Array,
	currFocused: 0,
	initialized: false,
	active: true,
	strings: {
		ok: "OK",
		cancel: "Cancel",
		alert: "Alert",
		confirm: "Confirm",
		loading: "Loading...",
		close: "Close"
	},
	options: {
		title: "ModalBox Window", // Title of the ModalBox window
		overlayClose: true, // Close modal box by clicking on overlay
		width: 500, // Default width in px
		height: 90, // Default height in px
		overlayOpacity: .65, // Default overlay opacity
		params: {},
		method: 'get', // Default Ajax request method
		autoFocusing: true, // Toggles auto-focusing for form elements. Disable for long text pages.
		showAfterLoading: false // if true, the box does not appear until the ajax request returns with the contents of the box. has no effect on non-ajax popups
	},
	_options: new Object,

	setOptions: function(options) {
		Object.extend(this.options, options || {});
	},

	setStrings: function(strings) {
		Object.extend(this.strings, strings || {});
	},

	_init: function(options) {
		// Setting up original options with default options
		Object.extend(this._options, this.options);
		this.setOptions(options);

		//Creating the overlay
		this.MBoverlay = new Element("div", { id: "MB_overlay", style: "opacity: 0; display: none" });

		//Creating the modal window
		this.MBwindow = new Element("div", {id: "MB_window", style: "display: none"}).update(
			this.MBframe = new Element("div", {id: "MB_frame"}).update(
				this.MBheader = new Element("div", {id: "MB_header"}).update(
					this.MBcaption = new Element("div", {id: "MB_caption"})
				)
			)
		);
		this.MBclose = new Element("a", {id: "MB_close", title: this.strings.close, href: "#"}).update("<span>&times;</span>");
		this.MBheader.insert({'bottom':this.MBclose});

		this.MBcontent = new Element("div", {id: "MB_content"}).update(
			this.MBloading = new Element("div", {id: "MB_loading"}).update(this.strings.loading)
		);
		this.MBframe.insert({'bottom':new Element("div",{id:'modal_message'})});
		this.MBframe.insert({'bottom':this.MBcontent});

		var injectToEl = $(document.body);
		injectToEl.insert({'top':this.MBwindow});
		injectToEl.insert({'top':this.MBoverlay});

		// Adding event observers
		this.hideObserver = this._hide.bindAsEventListener(this);
		this.kbdObserver = this._kbdHandler.bindAsEventListener(this);
		this._initObservers();

		this.initialized = true; // Mark as initialized
	},

	show: function(content, options) {
		if(!this.initialized) this._init(options); // Check for is already initialized

		if (this.MBwindow.style.display != "none") {
			this.priorContent.push({content: this.MBcontent.innerHTML, caption: this.MBcaption.innerHTML, width: this.options.width});
		}

		this.content = content;
		this.setOptions(options);

		if(this.options.title) // Updating title of the MB
			this.MBcaption.update(this.options.title);
		else { // If title isn't given, the header will not displayed
			this.MBheader.hide();
			this.MBcaption.hide();
		}

		if(this.MBwindow.style.display == "none") { // First modal box appearing
			this._appear();
			this.event("onShow"); // Passing onShow callback
		}
		else { // If MB already on the screen, update it
			this._update();
			this.event("onUpdate"); // Passing onUpdate callback
		}
	},

	// External hide method to use from external HTML and JS
	hide: function(options) {
		if(this.initialized) {
			// Reading for options/callbacks except if event given as a pararmeter
			if(options && typeof options.element != 'function') Object.extend(this.options, options);
			this.event("beforeHide");
			this.MBwindow.hide();
			this.priorContent = []; // added for cg
			this._deinit();
		}
	},

	// Internal hide method to use with overlay and close link
	_hide: function(event) {
		event.stop(); // Stop event propaganation for link elements
		// Then clicked on overlay we'll check the option and in case of overlayClose == false we'll break hiding execution [Fix for #139]
		if(event.element().id == 'MB_overlay' && !this.options.overlayClose) return false;
		this.hide();
	},

	// a replacement for standard alert(). modified heavily for cg.
	alert: function(message) {
		Object.extend(this.strings, {'message':message})
		var html = '<div class="MB_alert"><p>#{message}</p><input type="button" onclick="Modalbox.hide()" value="#{ok}" /></div>';
//		this.show(html.interpolate(this.strings), {title: this.strings.alert, width: 350});
		this.show(html.interpolate(this.strings), {title: this.strings.alert});
	},

	// displays a simple confirmation dialog
	// options for ajax: ok_function
	// options for http: method, action, token
	confirm: function(message, options) {
		options = $H(this.strings).merge(options).merge({'message':message})
		options.set('ok_function', options.get('ok_function') || 'this.form.submit()');
		if (options.get('action')) {
			if (options.get('method') == 'delete') {
				options.set('form_attrs', 'action="#{action}" method="post"'.interpolate(options));
			} else {
				options.set('form_attrs', 'action="#{action}" method="#{method}"'.interpolate(options));
			}
		}
		if (options.get('method') == 'get') {
			var hidden_fields = '';
		} else {
			var hidden_fields = '<input type="hidden" value="#{token}" name="authenticity_token"/><input type="hidden" value="#{method}" name="_method"/>'.interpolate(options);
		}
		var html = '<div class="MB_confirm">' +
			'<p>#{message}</p>' +
			'<form #{form_attrs}>' +
				'<img src="/images/spinner.gif" style="display:none" id="MB_spinner"/> ' +
				'<input type="button" onclick="Modalbox.back()" value="#{cancel}" />' +
				'<input type="button" onclick="#{ok_function}" value="#{ok}" />' +
				hidden_fields +
			'</form>' +
		'</div>';
		this.show(html.interpolate(options), {title: options.get('title'), width: 350});
	},

	// closes the modalbox, or restores the previous content if there was any.
	back: function() {
		var prior = this.priorContent.pop();
		if (prior) {
			this.show(prior.content, {title:prior.caption, width:prior.width});
		} else {
			this.hide();
		}
	},

	// turns on modalbox spinner
	spin: function() {$('MB_spinner').show()},

	_appear: function() { // First appearing of MB
		if(!this.options.showAfterLoading)
			this._makeVisible();
		this.loadContent();
		this._setWidthAndPosition = this._setWidthAndPosition.bindAsEventListener(this);
		Event.observe(window, "resize", this._setWidthAndPosition);
		this._setWidthAndPosition();
	},

	_update: function() { // Updating MB in case of wizards
		this.MBcontent.update(this.MBloading.update(this.strings.loading));
		this.loadContent();
	},

	loadContent: function () {
		if(this.event("beforeLoad") != false) { // If callback passed false, skip loading of the content
			if(typeof this.content == 'string') {
				var htmlRegExp = new RegExp(/<\/?[^>]+>/gi);
				if(htmlRegExp.test(this.content)) { // Plain HTML given as a parameter
					this._insertContent(this.content.stripScripts(), function(){
						this.content.extractScripts().map(function(script) {
							return eval(script.replace("<!--", "").replace("// -->", ""));
						}.bind(window));
					}.bind(this));
				} else // URL given as a parameter. We'll request it via Ajax
					new Ajax.Request( this.content, {
						method: this.options.method.toLowerCase(),
						parameters: this.options.params,
						onSuccess: function(transport) {this._loadContentSuccess(transport)}.bind(this),
						// added for cg
						evalScripts: true,
						onComplete: function(transport) {this.event('onComplete')}.bind(this),
						onLoading: function(transport) {this.event('onLoading')}.bind(this),
						// end cg
						onException: function(instance, exception){
							Modalbox.hide();
							throw('Modalbox Loading Error: ' + exception);
						}
					});

			} else if (typeof this.content == 'object') {// HTML Object is given
				this._insertContent(this.content);
			} else {
				Modalbox.hide();
				throw('Modalbox Parameters Error: Please specify correct URL or HTML element (plain HTML or object)');
			}
		}
	},

	_loadContentSuccess: function(transport) {
		// if the response is javascript, then it is probably the result of rjs, so do nothing.
		if (transport.getResponseHeader('Content-Type').match(/script/))
			return;
		if (this.options.showAfterLoading)
			this._makeVisible();
		this.event('onSuccess');
		this._insertContent(transport.responseText);
	},

	// replaces current content html with new html. ultimately, all updating of the content goes through this function.
	_insertContent: function(content, callback) {
		// Plain HTML is given
		if(typeof content == 'string') {
			this.MBcontent.update(new Element("div", { style: "display: none" }).update(content)).down().show();
		}
		// HTML Object is given
		else if (typeof content == 'object') {
			var _htmlObj = content.cloneNode(true); // If node already a part of DOM we'll clone it
			// If clonable element has ID attribute defined, modifying it to prevent duplicates
			if(content.id) content.id = "MB_" + content.id;
			/* Add prefix for IDs on all elements inside the DOM node */
			$(content).select('*[id]').each(function(el){ el.id = "MB_" + el.id; });
			this.MBcontent.update(_htmlObj).down('div').show();
			if(Prototype.Browser.IE) // Toggling back visibility for hidden selects in IE
				$$("#MB_content select").invoke('setStyle', {'visibility': ''});
		}
		this._setPosition();
		this._updateFocus();
	},

	// sets the dom elements to be visible
	_makeVisible: function() {
		this._removeIEScroll();
		this.MBoverlay.setStyle({opacity: this.options.overlayOpacity});
		this.MBoverlay.show();
		this.MBwindow.show();
	},

	_initObservers: function(){
		this.MBclose.observe("click", this.hideObserver);
		if(this.options.overlayClose)
			this.MBoverlay.observe("click", this.hideObserver);
		if(Prototype.Browser.Gecko)
			Event.observe(document, "keypress", this.kbdObserver); // Gecko is moving focus a way too fast
		else
			Event.observe(document, "keydown", this.kbdObserver); // All other browsers are okay with keydown
	},

	_removeObservers: function(){
		this.MBclose.stopObserving("click", this.hideObserver);
		if(this.options.overlayClose)
			this.MBoverlay.stopObserving("click", this.hideObserver);
		if(Prototype.Browser.Gecko)
			Event.stopObserving(document, "keypress", this.kbdObserver);
		else
			Event.stopObserving(document, "keydown", this.kbdObserver);
	},

	_updateFocus: function() {
		this.focusableElements = this._findFocusableElements();
		this._focusFirst();
	},

	// Setting focus to the first 'focusable' element which is one with tabindex = 1 or the first in the form loaded.
	_focusFirst: function() {
		if(this.focusableElements.length > 0 && this.options.autoFocusing == true) {
			var firstEl = this.focusableElements.find(function (el){
				return el.tabIndex == 1;
			}) || this.focusableElements.first();
			this.currFocused = this.focusableElements.toArray().indexOf(firstEl);
			firstEl.focus(); // Focus on first focusable element except close button
		} else if(this.MBclose.visible())
			this.MBclose.focus(); // If no focusable elements exist focus on close button
	},

	// Collect form elements or links from MB content
	_findFocusableElements: function() {
		if (Prototype.Browser.IE && this.MBcontent.select('iframe').length) {
			return []; // IE dies a horrible death if the modalbox includes an iframe, unless we return [] here.
                 // Not sure if it is the focus or the adding the class that triggers it.
		} else {
			this.MBcontent.select('input:not([type~=hidden]), select, textarea, button, a[href]').invoke('addClassName', 'MB_focusable');
			return this.MBcontent.select('.MB_focusable');
		}
	},

	_kbdHandler: function(event) {
		var node = event.element();
		switch(event.keyCode) {
			case Event.KEY_TAB:
				event.stop();

				/* Switching currFocused to the element which was focused by mouse instead of TAB-key. Fix for #134 */
				if(node != this.focusableElements[this.currFocused])
					this.currFocused = this.focusableElements.toArray().indexOf(node);

				if(!event.shiftKey) { //Focusing in direct order
					if(this.currFocused == this.focusableElements.length - 1) {
						this.focusableElements.first().focus();
						this.currFocused = 0;
					} else {
						this.currFocused++;
						this.focusableElements[this.currFocused].focus();
					}
				} else { // Shift key is pressed. Focusing in reverse order
					if(this.currFocused == 0) {
						this.focusableElements.last().focus();
						this.currFocused = this.focusableElements.length - 1;
					} else {
						this.currFocused--;
						this.focusableElements[this.currFocused].focus();
					}
				}
				break;
			case Event.KEY_ESC:
				if(this.active) this._hide(event);
				break;
			case 32:
				this._preventScroll(event);
				break;
			case 0: // For Gecko browsers compatibility
				if(event.which == 32) this._preventScroll(event);
				break;
			case Event.KEY_UP:
			case Event.KEY_DOWN:
			case Event.KEY_PAGEDOWN:
			case Event.KEY_PAGEUP:
			case Event.KEY_HOME:
			case Event.KEY_END:
				// Safari operates in slightly different way. This realization is still buggy in Safari.
				if(Prototype.Browser.WebKit && !["textarea", "select"].include(node.tagName.toLowerCase()))
					event.stop();
				else if( (node.tagName.toLowerCase() == "input" && ["submit", "button"].include(node.type)) || (node.tagName.toLowerCase() == "a") )
					event.stop();
				break;
		}
	},

	_preventScroll: function(event) { // Disabling scrolling by "space" key
		if(!["input", "textarea", "select", "button"].include(event.element().tagName.toLowerCase()))
			event.stop();
	},

	_deinit: function()
	{
		this._removeObservers();
		Event.stopObserving(window, "resize", this._setWidthAndPosition );
		this._removeElements();
		//this.MBcontent.setStyle({overflow: '', height: ''});
	},

	_removeElements: function () {
		this.MBoverlay.remove();
		this.MBwindow.remove();
		this._restoreIEScroll();

		// Replacing prefixes 'MB_' in IDs for the original content
		if(typeof this.content == 'object') {
			if(this.content.id && this.content.id.match(/MB_/)) {
				this.content.id = this.content.id.replace(/MB_/, "");
			}
			this.content.select('*[id]').each(function(el){ el.id = el.id.replace(/MB_/, ""); });
		}
		this.initialized = false;
		this.event("afterHide");
		this.setOptions(this._options); // restore defaults
	},

	_setPosition: function () {
		this.MBwindow.setStyle({left: ((this.MBoverlay.getWidth() - this.MBwindow.getWidth()) / 2 ) + "px"});
		var height = document.viewport.getHeight()
		if (this.MBcontent.getHeight() + this.MBheader.getHeight() > height) {
			this.MBframe.setStyle({overflow: 'auto', height: height + 'px'});
		} else {
			this.MBframe.setStyle({height: 'auto'});
		}
	},

	_setWidthAndPosition: function () {
		this.MBwindow.setStyle({width: this.options.width + "px"});
		this._setPosition();
	},

	// should be called when you have programatically altered the size of the modalbox.
	updatePosition: function () {
		this._setPosition();
	},

    _removeIEScroll: function() {
		if(Prototype.Browser.IE6) {
			this.initScrollX = window.pageXOffset || document.body.scrollLeft || document.documentElement.scrollLeft;
			this.initScrollY = window.pageYOffset || document.body.scrollTop || document.documentElement.scrollTop;
			window.scrollTo(0,0);
			$$('html, body').invoke('setStyle', {width: "100%", height: "100%", overflow: "hidden"});
		}
	},
	_restoreIEScroll: function() {
		if(Prototype.Browser.IE6) {
			$$('html, body').invoke('setStyle', {width: "auto", height: "auto", overflow: ""});
			window.scrollTo(this.initScrollX, this.initScrollY);
		}
	},

	event: function(eventName) {
		try {
			if(this.options[eventName]) {
				var returnValue = this.options[eventName](); // Executing callback
				this.options[eventName] = null; // Removing callback after execution
				if(returnValue != undefined)
					return returnValue;
				else
					return true;
			}
			return true;
		} catch(e) {}
	}
};

Object.extend(Modalbox, Modalbox.Methods);
