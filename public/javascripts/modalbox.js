/*
ModalBox - The pop-up window thingie with AJAX, based on prototype and script.aculo.us.

Copyright Andrey Okonetchnikov (andrej.okonetschnikow@gmail.com), 2006-2007
All rights reserved.

VERSION 1.6.1
Last Modified: 04/13/2008

MODIFICATIONS FOR CRABGRASS:

(1) commented out transitions (this will make the file smaller when minified)
(2) added some ajax request event listeners
(3) added option showAfterLoading
(4) added Modalbox.confirm()
(5) stripped out all the resize code. it seems to only be needed for fancy animation, but makes everything more complicated.

THE EVENT LISTENERS:

* beforeLoad — fires right before loading contents into the ModalBox. If the callback function returns false, content loading will skipped. This can be used for redirecting user to another MB-page for authorization purposes for example.
* afterLoad — fires after loading content into the ModalBox (i.e. after showing or updating existing window).
* beforeHide — fires right before removing elements from the DOM. Might be useful to get form values before hiding modalbox.
* afterHide — fires after hiding ModalBox from the screen.
* afterResize — fires after calling resize method.
* onShow — fires on first appearing of ModalBox before the contents are being loaded.
* onUpdate — fires on updating the content of ModalBox (on call of Modalbox.show method from active ModalBox instance).

New event listeners added for crabgrass:

* onComplete -- called when ajax request finishes
* onLoading  -- called when ajax request starts loading
* onSuccess  -- called when ajax request returns success

*/



if (!window.Modalbox)
	var Modalbox = new Object();

Modalbox.Methods = {
	overrideAlert: true, // Override standard browser alert message with ModalBox
	focusableElements: new Array,
	priorContent: new Array,             // added for cg
	currFocused: 0,
	initialized: false,
	active: true,
	strings: {
		ok: "OK",
		cancel: "Cancel",
		alert: "Alert",
		confirm: "Confirm"
	},
	options: {
		title: "ModalBox Window", // Title of the ModalBox window
		overlayClose: true, // Close modal box by clicking on overlay
		width: 500, // Default width in px
		height: 90, // Default height in px
		overlayOpacity: .65, // Default overlay opacity
//		overlayDuration: .25, // Default overlay fade in/out duration in seconds
//		slideDownDuration: .5, // Default Modalbox appear slide down effect in seconds
//		slideUpDuration: .5, // Default Modalbox hiding slide up effect in seconds
//		resizeDuration: .25, // Default resize duration seconds
		inactiveFade: true, // Fades MB window on inactive state
//		transitions: true, // Toggles transition effects. Transitions are enabled by default
		loadingString: "", // Default loading string message
		closeString: "Close window", // Default title attribute for close window link
		closeValue: "&times;", // Default string for close link in the header
		params: {},
		method: 'get', // Default Ajax request method
		autoFocusing: true, // Toggles auto-focusing for form elements. Disable for long text pages.
		aspnet: false, // Should be use then using with ASP.NET costrols. Then true Modalbox window will be injected into the first form element.
		showAfterLoading: false // added for cg. if true, the box does not appear until the ajax request returns
                                // with the contents of the box. has no effect on non-ajax popups
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
		this.MBoverlay = new Element("div", { id: "MB_overlay", style: "opacity: 0" });

		//Creating the modal window
		this.MBwindow = new Element("div", {id: "MB_window", style: "display: none"}).update(
			this.MBframe = new Element("div", {id: "MB_frame"}).update(
				this.MBheader = new Element("div", {id: "MB_header"}).update(
					this.MBcaption = new Element("div", {id: "MB_caption"})
				)
			)
		);
		this.MBclose = new Element("a", {id: "MB_close", title: this.options.closeString, href: "#"}).update("<span>" + this.options.closeValue + "</span>");
		this.MBheader.insert({'bottom':this.MBclose});

		this.MBcontent = new Element("div", {id: "MB_content"}).update(
			this.MBloading = new Element("div", {id: "MB_loading"}).update(this.options.loadingString)
		);
		this.MBframe.insert({'bottom':this.MBcontent});

		// Inserting into DOM. If parameter set and form element have been found will inject into it. Otherwise will inject into body as topmost element.
		// Be sure to set padding and marging to null via CSS for both body and (in case of asp.net) form elements.
		var injectToEl = this.options.aspnet ? $(document.body).down('form') : $(document.body);
		injectToEl.insert({'top':this.MBwindow});
		injectToEl.insert({'top':this.MBoverlay});

		// Initial scrolling position of the window. To be used for remove scrolling effect during ModalBox appearing
		this.initScrollX = window.pageXOffset || document.body.scrollLeft || document.documentElement.scrollLeft;
		this.initScrollY = window.pageYOffset || document.body.scrollTop || document.documentElement.scrollTop;

		//Adding event observers
		this.hideObserver = this._hide.bindAsEventListener(this);
		this.kbdObserver = this._kbdHandler.bindAsEventListener(this);
		this._initObservers();

		this.initialized = true; // Mark as initialized
	},

	show: function(content, options) {
		if(!this.initialized) this._init(options); // Check for is already initialized

		// added for cg
		if (this.MBwindow.style.display != "none") {
			this.priorContent.push({content: $(this.MBcontent).innerHTML, caption: $(this.MBcaption).innerHTML, width: this.options.width});
		} // end

		this.content = content;
		this.setOptions(options);

		if(this.options.title) // Updating title of the MB
			$(this.MBcaption).update(this.options.title);
		else { // If title isn't given, the header will not displayed
			$(this.MBheader).hide();
			$(this.MBcaption).hide();
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

	hide: function(options) { // External hide method to use from external HTML and JS
		if(this.initialized) {
			// Reading for options/callbacks except if event given as a pararmeter
			if(options && typeof options.element != 'function') Object.extend(this.options, options);
			// Passing beforeHide callback
			this.event("beforeHide");
//			if(this.options.transitions)
//				Effect.SlideUp(this.MBwindow, { duration: this.options.slideUpDuration, transition: Effect.Transitions.sinoidal, afterFinish: this._deinit.bind(this) } );
//			else {
				$(this.MBwindow).hide();
				this.priorContent = []; // added for cg
				this._deinit();
//			}
		} else throw("Modalbox is not initialized.");
	},

	_hide: function(event) { // Internal hide method to use with overlay and close link
		event.stop(); // Stop event propaganation for link elements
		/* Then clicked on overlay we'll check the option and in case of overlayClose == false we'll break hiding execution [Fix for #139] */
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

	// we cannot replace the standard confirm directly, because of the way it halts js execution.
	// this, however, can be used to in combination with a custom helper.
	// options for ajax: ok_function
	// options for form: method, action, token
	// added for cg
	confirm: function(message, options) {
		options = $H(this.strings).merge(options).merge({'message':message})
		if (options.get('action')) {
			var html = '<div class="MB_confirm"><p>#{message}</p><form class="button-to" action="#{action}" method="#{method}"><input type="button" onclick="Modalbox.hide()" value="#{cancel}" /><input type="submit" value="#{ok}"/><input type="hidden" value="#{token}" name="authenticity_token"/></form></div>';
		} else if (options.get('ok_function')) {
			var html = '<div class="MB_confirm"><p>#{message}</p><form><img src="/images/spinner.gif" style="display:none" id="MB_spinner"/> <input type="button" onclick="Modalbox.back()" value="#{cancel}" /><input type="button" onclick="#{ok_function}" value="#{ok}" /></form></div>';
		}
		this.show(html.interpolate(options), {title: options.get('title'), width: 350});
		//if (this.priorContent.size())
		//	this.resizeToContent();
	},

	// closes the modalbox, or restores the previous content if there was any.
	// added for cg
	back: function() {
		var prior = this.priorContent.pop();
		if (prior) {
			this.show(prior.content, {title:prior.caption, width:prior.width});
			//this.resizeToContent();
		} else {
			this.hide();
		}
	},

	// turns on modalbox spinner
	// added for cg
	spin: function() {$('MB_spinner').show()},

	_appear: function() { // First appearing of MB
		if(Prototype.Browser.IE && !navigator.appVersion.match(/\b7.0\b/)) { // Preparing IE 6 for showing modalbox
			window.scrollTo(0,0);
			this._prepareIE("100%", "hidden");
		}
//		this._setWidth();
//		this._setPosition();
		if(!this.options.showAfterLoading) {
	//		if(this.options.transitions) {
	//			$(this.MBoverlay).setStyle({opacity: 0});
	//			new Effect.Fade(this.MBoverlay, {
	//					from: 0,
	//					to: this.options.overlayOpacity,
	//					duration: this.options.overlayDuration,
	//					afterFinish: function() {
	//						new Effect.SlideDown(this.MBwindow, {
	//							duration: this.options.slideDownDuration,
	//							transition: Effect.Transitions.sinoidal,
	//							afterFinish: function(){
	//								this._setPosition();
	//								this.loadContent();
	//							}.bind(this)
	//						});
	//					}.bind(this)
	//			});
	//		} else {
				$(this.MBwindow).show();
				this.loadContent();
				$(this.MBoverlay).setStyle({opacity: this.options.overlayOpacity});
	//		}
		} else {
			this.MBoverlay.hide();
			this.loadContent();
		}
		this._setWidthAndPosition = this._setWidthAndPosition.bindAsEventListener(this);
		Event.observe(window, "resize", this._setWidthAndPosition);
		this._setWidthAndPosition();
	},

//	resize: function(byWidth, byHeight, options) { // Change size of MB without loading content
//		var oWidth = $(this.MBoverlay).getWidth();
//		var wHeight = $(this.MBwindow).getHeight();
//		var wWidth = $(this.MBwindow).getWidth();
//		var cHeight = $(this.MBcontent).getHeight();
//		var newHeight = ((wHeight - hHeight + byHeight) < cHeight) ? (cHeight + hHeight) : (wHeight + byHeight);
//		var newWidth = wWidth + byWidth;
//		this.options.width = newWidth;
//		if(options) this.setOptions(options); // Passing callbacks
////		if(this.options.transitions) {
////			new Effect.Morph(this.MBwindow, {
////				style: "width:" + newWidth + "px; height:" + newHeight + "px; left:" + ((oWidth - newWidth)/2) + "px",
////				duration: this.options.resizeDuration,
////				beforeStart: function(fx){
////					fx.element.setStyle({overflow:"hidden"}); // Fix for MSIE 6 to resize correctly
////				},
////				afterFinish: function(fx) {
////					fx.element.setStyle({overflow:"visible"});
////					this.event("_afterResize"); // Passing internal callback
////					this.event("afterResize"); // Passing callback
////				}.bind(this)
////			});
////		} else {
//			//this.MBwindow.setStyle({width: newWidth + "px", height: newHeight + "px"});
//			this.MBwindow.setStyle({width: newWidth + "px"}); // mod for cg
//			setTimeout(function() {
//				this.event("_afterResize"); // Passing internal callback
//				this.event("afterResize"); // Passing callback
//			}.bind(this), 1);
////		}
//	},

//	resizeToContent: function(options){

//		// Resizes the modalbox window to the actual content height.
//		// This might be useful to resize modalbox after some content modifications which were changed ccontent height.

//		var byHeight = this.options.height - $(this.MBwindow).getHeight();
//		if(byHeight != 0) {
//			if(options) this.setOptions(options); // Passing callbacks
//			Modalbox.resize(0, byHeight);
//		}
//	},

//	resizeToInclude: function(element, options){

//		// Resizes the modalbox window to the camulative height of element. Calculations are using CSS properties for margins and border.
//		// This method might be useful to resize modalbox before including or updating content.

//		var el = $(element);
//		var elHeight = el.getHeight() + parseInt(el.getStyle('margin-top'), 0) + parseInt(el.getStyle('margin-bottom'), 0) + parseInt(el.getStyle('border-top-width'), 0) + parseInt(el.getStyle('border-bottom-width'), 0);
//		if(elHeight > 0) {
//			if(options) this.setOptions(options); // Passing callbacks
//			Modalbox.resize(0, elHeight);
//		}
//	},

	_update: function() { // Updating MB in case of wizards
		$(this.MBcontent).update($(this.MBloading).update(this.options.loadingString));
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
		// added for cg
		// if the response is javascript, then it is probably the result of rjs, so do nothing.
		if (transport.getResponseHeader('Content-Type').match(/script/))
			return;
		this.event('onSuccess');
		if (this.options.showAfterLoading) {
			this.MBoverlay.setStyle({opacity: this.options.overlayOpacity});
			this.MBoverlay.show();
			this.MBwindow.show();
		}
		// end cg

		this._insertContent(transport.responseText);
//		var response = new String(transport.responseText);
//		this._insertContent(transport.responseText.stripScripts(), function(){
//			response.extractScripts().map(function(script) {
//				return eval(script.replace("<!--", "").replace("// -->", ""));
//			}.bind(window));
//		});
	},

	_insertContent: function(content, callback){
//		$(this.MBcontent).hide().update("");
		if(typeof content == 'string') { // Plain HTML is given
			this.MBcontent.update(new Element("div", { style: "display: none" }).update(content)).down().show();
		} else if (typeof content == 'object') { // HTML Object is given
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
		// Prepare and resize modal box for content
//		if(this.options.height == this._options.height) {
//			try { dim = this.MBwindow.getDimensions(); } catch(e) {}
//			Modalbox.resize((this.options.width - dim.width), this.MBcontent.getHeight() - dim.height + this.MBheader.getHeight(), {
//				afterResize: function(){
//					setTimeout(function(){ // MSIE fix
//						this._putContent(callback);
//					}.bind(this),1);
//				}.bind(this)
//			});
//		} else { // Height is defined. Creating a scrollable window
//			this._setWidth();
//			this.MBcontent.setStyle({overflow: 'auto', height: $(this.MBwindow).getHeight() - $(this.MBheader).getHeight() - 13 + 'px'});
//			setTimeout(function(){ // MSIE fix
//				this._putContent(callback);
//			}.bind(this),1);
//		}
	},

	_putContent: function(callback){
		this.MBcontent.show();
		this.focusableElements = this._findFocusableElements();
		this._setFocus(); // Setting focus on first 'focusable' element in content (input, select, textarea, link or button)
		if(callback != undefined)
			callback(); // Executing internal JS from loaded content
		this.event("afterLoad"); // Passing callback
	},

	activate: function(options){
		this.setOptions(options);
		this.active = true;
		$(this.MBclose).observe("click", this.hideObserver);
		if(this.options.overlayClose)
			$(this.MBoverlay).observe("click", this.hideObserver);
		$(this.MBclose).show();
//		if(this.options.transitions && this.options.inactiveFade)
//			new Effect.Appear(this.MBwindow, {duration: this.options.slideUpDuration});
	},

	deactivate: function(options) {
		this.setOptions(options);
		this.active = false;
		$(this.MBclose).stopObserving("click", this.hideObserver);
		if(this.options.overlayClose)
			$(this.MBoverlay).stopObserving("click", this.hideObserver);
		$(this.MBclose).hide();
//		if(this.options.transitions && this.options.inactiveFade)
//			new Effect.Fade(this.MBwindow, {duration: this.options.slideUpDuration, to: .75});
	},

	_initObservers: function(){
		$(this.MBclose).observe("click", this.hideObserver);
		if(this.options.overlayClose)
			$(this.MBoverlay).observe("click", this.hideObserver);
		if(Prototype.Browser.Gecko)
			Event.observe(document, "keypress", this.kbdObserver); // Gecko is moving focus a way too fast
		else
			Event.observe(document, "keydown", this.kbdObserver); // All other browsers are okay with keydown
	},

	_removeObservers: function(){
		$(this.MBclose).stopObserving("click", this.hideObserver);
		if(this.options.overlayClose)
			$(this.MBoverlay).stopObserving("click", this.hideObserver);
		if(Prototype.Browser.Gecko)
			Event.stopObserving(document, "keypress", this.kbdObserver);
		else
			Event.stopObserving(document, "keydown", this.kbdObserver);
	},

	_setFocus: function() {
		/* Setting focus to the first 'focusable' element which is one with tabindex = 1 or the first in the form loaded. */
		if(this.focusableElements.length > 0 && this.options.autoFocusing == true) {
			var firstEl = this.focusableElements.find(function (el){
				return el.tabIndex == 1;
			}) || this.focusableElements.first();
			this.currFocused = this.focusableElements.toArray().indexOf(firstEl);
			firstEl.focus(); // Focus on first focusable element except close button
		} else if($(this.MBclose).visible())
			$(this.MBclose).focus(); // If no focusable elements exist focus on close button
	},

	_findFocusableElements: function(){ // Collect form elements or links from MB content
		this.MBcontent.select('input:not([type~=hidden]), select, textarea, button, a[href]').invoke('addClassName', 'MB_focusable');
		return this.MBcontent.select('.MB_focusable');
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
//		if(this.options.transitions) {
//			Effect.toggle(this.MBoverlay, 'appear', {duration: this.options.overlayDuration, afterFinish: this._removeElements.bind(this) });
//		} else {
			this.MBoverlay.hide();
			this._removeElements();
//		}
		$(this.MBcontent).setStyle({overflow: '', height: ''});
	},

	_removeElements: function () {
		$(this.MBoverlay).remove();
		$(this.MBwindow).remove();
		if(Prototype.Browser.IE && !navigator.appVersion.match(/\b7.0\b/)) {
			this._prepareIE("", ""); // If set to auto MSIE will show horizontal scrolling
			window.scrollTo(this.initScrollX, this.initScrollY);
		}

		/* Replacing prefixes 'MB_' in IDs for the original content */
		if(typeof this.content == 'object') {
			if(this.content.id && this.content.id.match(/MB_/)) {
				this.content.id = this.content.id.replace(/MB_/, "");
			}
			this.content.select('*[id]').each(function(el){ el.id = el.id.replace(/MB_/, ""); });
		}
		/* Initialized will be set to false */
		this.initialized = false;
		this.event("afterHide"); // Passing afterHide callback
		this.setOptions(this._options); //Settings options object into intial state
	},

	_setWidth: function () { //Set size
		$(this.MBwindow).setStyle({width: this.options.width + "px", height: this.options.height + "px"});
	},

	_setPosition: function () {
		this.MBwindow.setStyle({left: ((this.MBoverlay.getWidth() - this.MBwindow.getWidth()) / 2 ) + "px"});
		var height = document.viewport.getHeight()
		if (this.MBcontent.getHeight() + this.MBheader.getHeight() > height) {
			this.MBframe.setStyle({overflow: 'auto', height: height + 'px'});
			setTimeout(function(){ this._putContent(); }.bind(this),1); // MSIE fix
		} else {
			this.MBframe.setStyle({height: 'auto'});
		}
	},

	_setWidthAndPosition: function () {
		$(this.MBwindow).setStyle({width: this.options.width + "px"});
		this._setPosition();
	},

	// should be called when you have programatically altered the size of the modalbox.
	updatePosition: function () {
		this._setPosition();
	},

	_getScrollTop: function () { //From: http://www.quirksmode.org/js/doctypes.html
		var theTop;
		if (document.documentElement && document.documentElement.scrollTop)
			theTop = document.documentElement.scrollTop;
		else if (document.body)
			theTop = document.body.scrollTop;
		return theTop;
	},

	_prepareIE: function(height, overflow){
		$$('html, body').invoke('setStyle', {width: height, height: height, overflow: overflow}); // IE requires width and height set to 100% and overflow hidden
		$$("select").invoke('setStyle', {'visibility': overflow}); // Toggle visibility for all selects in the common document
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
