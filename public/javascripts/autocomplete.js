/*
 *
 *  Ajax Autocomplete for Prototype, version 1.0.3
 *  (c) 2008 Tomas Kirda
 *
 *  Ajax Autocomplete for Prototype is freely distributable under the terms of an MIT-style license.
 *  For details, see the web site: http://www.devbridge.com/projects/autocomplete/
 *
 */

var Autocomplete = function(el, options, id){
  this.el = $(el);
  this.id = id ? id : this.el.identify();
  this.el.setAttribute('autocomplete','off');
  this.suggestions = [];
  this.data = [];
  this.badQueries = [];
  this.selectedIndex = -1;
  this.currentValue = this.el.value;
  this.intervalId = 0;
  this.preloadedSuggestions = 0;
  this.renderedQuery = "";
  this.cachedResponse = [];
  this.instanceId = null;
  this.onChangeInterval = null;
  this.ignoreValueChange = false;
  this.messageDisplayed = false;
  this.ignoreUpdates = false;
  this.serviceUrl = options.serviceUrl;
  this.options = {
    autoSubmit:false,
    minChars:1,
    maxHeight:300,
    deferRequestBy:0,
    width:0,
    container:null,
    message:"",
    preloadedOnTop:false
  };
  if(options){ Object.extend(this.options, options); }
  if(Autocomplete.isDomLoaded){
    this.initialize();
  }else{
    Event.observe(document, 'dom:loaded', this.initialize.bind(this), false);
  }
};

Autocomplete.instances = [];
Autocomplete.isDomLoaded = false;

Autocomplete.getInstance = function(id){
  var instances = Autocomplete.instances;
  var i = instances.length;
  while(i--){ if(instances[i].id === id){ return instances[i]; }}
};

Autocomplete.highlight = function(value, re){
  return value.replace(re, function(match){ return '<ins>' + match + '<\/ins>' });
};

Autocomplete.hideAll = function() {
  Autocomplete.instances.invoke('hide');
};

Autocomplete.prototype = {

  killerFn: null,

  initialize: function() {
    var me = this;
    this.killerFn = function(e) {
      if (!$(Event.element(e)).up('.autocomplete')) {
        me.killSuggestions();
        me.disableKillerFn();
      }
    }.bindAsEventListener(this);

    if (!this.options.width) { this.options.width = this.el.getWidth(); }

    var div = new Element('div', { style: 'position:absolute;', "class":"autocomplete_holder" });
    div.update('<div class="autocomplete-w1"><div class="autocomplete-w2"><div class="autocomplete" id="Autocomplete_' + this.id + '" style="display:none; width:' + this.options.width + 'px;"></div></div></div>');

    this.options.container = $(this.options.container);
    if (this.options.container) {
      this.options.container.appendChild(div);
      this.fixPosition = function() { };
    } else {
      document.body.appendChild(div);
    }

    this.mainContainerId = div.identify();
    this.container = $('Autocomplete_' + this.id);
    this.fixPosition();

    Event.observe(this.el, window.opera ? 'keypress':'keydown', this.onKeyPress.bind(this));
    Event.observe(this.el, 'keyup', this.onKeyUp.bind(this));
    Event.observe(this.el, 'blur', this.enableKillerFn.bind(this));
    Event.observe(this.el, 'click', this.clearMessage.bind(this));

    // If we have preloaded data we might want to display it on focus.
    Event.observe(this.el, 'focus', this.fixPosition.bind(this));

    // when we no longer have focus, ignore updates from prior ajax requests.
    Event.observe(this.el, 'blur', function(){this.ignoreUpdates = true;}.bind(this));
    Event.observe(this.el, 'focus', function(){this.ignoreUpdates = false;}.bind(this));

    this.container.setStyle({ maxHeight: this.options.maxHeight + 'px' });
    if (this.options.message != "") {
      this.el.setStyle({ color: '#808080' });
      this.el.value = this.options.message;
      this.messageDisplayed=true;
    }
    this.instanceId = Autocomplete.instances.push(this) - 1;
    /* I think we should trigger a preloading request from here */
    this.requestSuggestions("");
  },

  fixPosition: function() {
    var offset = this.el.cumulativeOffset();
    $(this.mainContainerId).setStyle({ top: (offset.top + this.el.getHeight()) + 'px', left: offset.left + 'px' });
  },

  enableKillerFn: function() {
    Event.observe(document.body, 'click', this.killerFn);
    Event.observe(document.body, 'click', this.hide.bind(this));
  },

  disableKillerFn: function() {
    Event.stopObserving(document.body, 'click', this.killerFn);
  },

  killSuggestions: function() {
    this.stopKillSuggestions();
    this.intervalId = window.setInterval(function() { this.hide(); this.stopKillSuggestions(); } .bind(this), 300);
  },

  stopKillSuggestions: function() {
    window.clearInterval(this.intervalId);
  },

  onKeyPress: function(e) {
    if (!this.enabled) { return; }
    // return will exit the function
    // and event will not fire
    switch (e.keyCode) {
      case Event.KEY_ESC:
        this.el.value = this.currentValue;
        this.hide();
        break;
      case Event.KEY_TAB:
      case Event.KEY_RETURN:
        if (this.selectedIndex === -1) {
          this.hide();
          return;
        }
        this.select(this.selectedIndex);
        if (e.keyCode === Event.KEY_TAB) { return; }
        break;
      case Event.KEY_UP:
        this.moveUp();
        break;
      case Event.KEY_DOWN:
        this.moveDown();
        break;
      default:
        return;
    }
    Event.stop(e);
  },

  onKeyUp: function(e) {
    this.clearMessage();
    switch (e.keyCode) {
      case Event.KEY_UP:
      case Event.KEY_DOWN:
        return;
    }
    clearInterval(this.onChangeInterval);
    if (this.currentValue !== this.el.value) {
      if (this.options.deferRequestBy > 0) {
        // Defer lookup in case when value changes very quickly:
        this.onChangeInterval = setInterval((function() {
          this.onValueChange();
        }).bind(this), this.options.deferRequestBy);
      } else {
        this.onValueChange();
      }
    }
  },

  onValueChange: function() {
    clearInterval(this.onChangeInterval);
    this.currentValue = this.el.value;
    this.selectedIndex = -1;
    if (this.ignoreValueChange) {
      this.ignoreValueChange = false;
      return;
    }
    if (this.currentValue === '') {
      this.hide();
    } else if (this.currentValue.length < this.options.minChars) {
      /* display preloaded suggestions if there are any. */
      this.updateSuggestions("");
      this.suggest();
    } else {
      this.getSuggestions();
      this.suggest();
    }
  },

  clearMessage: function() {
    if (this.messageDisplayed) {
      this.el.setStyle({ color: '#000000' });
      var start = this.options.message.length;
      var end = this.el.value.length;
      var typed = this.el.value.substring(start,end);
      if (typed) {
        this.el.value = typed
      }
      else {
        this.el.value = ""
      }
      this.messageDisplayed=false;
    }
  },


  getSuggestions: function() {
    var cr = this.cachedResponse[this.currentValue];
    if (cr && Object.isArray(cr.suggestions)) {
      this.updateSuggestions(cr);
      return;
    }
    if (this.isBadQuery(this.currentValue)) {return;}
    /*
     * First we check if we have the cachedResponse from a previous query.
     * If we do and it has less than 20 suggestions it has a full result set and all we need to do is
     * filter these results to build the new result set.
     */
    var l = this.currentValue.length - 1;
    var cr1 = this.cachedResponse[this.currentValue.substring(0,l)];
    while (l-- >= this.options.minChars && !cr1) {
      cr1 = this.cachedResponse[this.currentValue.substring(0,l)];
    }
    if (cr1 && Object.isArray(cr1.suggestions)) {
      if (cr1.suggestions.length < 20) {
        this.cachedResponse[this.currentValue] = this.filterResponse(cr1);
        this.updateSuggestions(this.cachedResponse[this.currentValue]);
      } else {
        this.updateSuggestions(this.filterResponse(cr1));
        this.requestSuggestions(this.currentValue);
      }
      if (this.suggestions.length === 0 && this.currentValue.length >= this.options.minChars) {
        this.badQueries.push(this.currentValue);
      }
    } else {
      this.requestSuggestions(this.currentValue);
      this.updateSuggestions("");
    }
  },

  // This function filters the response results using the current search terms.
  // For a response result to be included in the results, it must match all the
  // search terms.
  //
  // This is accomplished by converting each search term into a regular expression.
  // Each regexp is prefixed by [\s\+>^] because we are looking for words outside
  // any possible the html tags.
  filterResponse: function(response) {
    var suggest =[];
    var data = [];
    var terms = this.currentValue.match(/\w+/g);
    if (terms) {
      // build array of search term regexps
      var regexps = [];
      terms.each( function(term, i) {
        regexps.push(new RegExp('[\\s\\+>_-]' + term + '|^' + term, 'i'));
      });
      // match this against each response suggestion
      response.suggestions.each( function(value, i) {
        var all_matched = regexps.all( function(regexp) {
          return value.match(regexp);
        });
        if (all_matched) {
          suggest.push(value);
          data.push(response.data[i]);
        }
      });
    }
    return {data:data, query:this.currentValue, suggestions:suggest};
  },

  isBadQuery: function(q) {
    var i = this.badQueries.length;
    while (i--) {
      if (q.indexOf(this.badQueries[i]) === 0) { return true; }
    }
    return false;
  },

  hide: function() {
    this.enabled = false;
    this.selectedIndex = -1;
    this.container.hide();
  },

  suggest: function() {
    var content = [];
    if (this.suggestions.length === 0) {
      this.hide();
      return;
    }
    this.suggestions.each(function (value, i) {
/* Haven't gotten a hr to work with both the mouse over as well as the key downs.
 * TODO: add it as special element to the suggestions array so the array and the
 *       display are in sync index wise. We just leave it out until that's done.
 *     if (i == this.preloadedSuggestions && i > 0 && i < this.suggestions.length) {
 *       content.push('<hr/>');
 *     }
 */
      content.push(this.displaySuggestion(value, i, this.data[i]));
    }.bind(this));
    this.enabled = true;
    this.fixPosition();
    this.container.update(content.join(''));
    if (!this.ignoreUpdates)
      this.container.show();
  },

  displaySuggestion: function(value, i, data) {
    var content = [];
    var re = new RegExp('\\b' + this.currentValue.match(/\w+/g).join('|\\b'), 'gi');
    content.push((this.selectedIndex === i ? '<div class="selected"' : '<div'),
      ' onclick="Autocomplete.instances[', this.instanceId, '].select(', i, ');"',
      ' onmouseover="Autocomplete.instances[', this.instanceId, '].activate(', i, ');">',
      this.renderRow(value, re, data),
      '</div>');
    return content.join('');
  },

  /* This will append the Suggestions from a cached response to the
   * display.
   */
  appendSuggestions: function(response) {
    this.suggestions = this.suggestions.concat(response.suggestions);
    this.data = this.data.concat(response.data);
  },

  requestSuggestions: function(query) {
    new Ajax.Request(this.serviceUrl, {
          parameters: { query: query },
          onComplete: this.processResponse.bind(this),
          method: 'get'
        });
  },

  processResponse: function(xhr) {
    var response;
    try {
      response = xhr.responseText.evalJSON();
      if (!Object.isArray(response.data)) { response.data = []; }
    } catch (err) { return; }
    this.cachedResponse[response.query] = response;
    if (this.currentValue.indexOf(response.query) === 0 &&
        response.query.length >= this.renderedQuery.length) {
      this.updateSuggestions(this.filterResponse(response));
      this.suggest();
    }
    if (this.suggestions.length === 0 && response.query.length >= this.minChars) { this.badQueries.push(response.query);}
  },

  /* this will update the Suggestions with the given response.
   * if response is "" only preloaded Suggestions will be used.
   */
  updateSuggestions: function(response) {
    this.suggestions=[]
    this.data=[]
    if (this.cachedResponse[""] && this.options.preloadedOnTop) {
      var filtered = this.filterResponse(this.cachedResponse[""]);
      this.appendSuggestions(filtered); /*adding preloaded suggestions*/
    }
    this.preloadedSuggestions=this.suggestions.length
    if (response != "") {
      this.appendSuggestions(response);
      this.renderedQuery=response.query;
    }
  },

  activate: function(index) {
    var divs = this.container.childNodes;
    var activeItem;
    // Clear previous selection:
    if (this.selectedIndex !== -1 && divs.length > this.selectedIndex) {
      divs[this.selectedIndex].className = '';
    }
    this.selectedIndex = index;
    if (this.selectedIndex !== -1 && divs.length > this.selectedIndex) {
      activeItem = divs[this.selectedIndex]
      activeItem.className = 'selected';
    }
    return activeItem;
  },

  deactivate: function(div, index) {
    div.className = '';
    if (this.selectedIndex === index) { this.selectedIndex = -1; }
  },

  select: function(i) {
    var selectedValue = this.suggestions[i];
    if (selectedValue) {
      this.el.value = this.selectValue(selectedValue);
      if (this.options.autoSubmit && this.el.form) {
        this.el.form.submit();
      }
      this.ignoreValueChange = true;
      this.hide();
      this.onSelect(i);
    }
  },

  moveUp: function() {
    if (this.selectedIndex === -1) { return; }
    if (this.selectedIndex === 0) {
      this.container.childNodes[0].className = '';
      this.selectedIndex = -1;
      this.el.value = this.currentValue;
      return;
    }
    this.adjustScroll(this.selectedIndex - 1);
  },

  moveDown: function() {
    if (this.selectedIndex === (this.suggestions.length - 1)) { return; }
    this.adjustScroll(this.selectedIndex + 1);
  },

  adjustScroll: function(i) {
    var container = this.container;
    var activeItem = this.activate(i);
    var offsetTop = activeItem.offsetTop;
    var upperBound = container.scrollTop;
    var lowerBound = upperBound + this.options.maxHeight - 25;
    if (offsetTop < upperBound) {
      container.scrollTop = offsetTop;
    } else if (offsetTop > lowerBound) {
      container.scrollTop = offsetTop - this.options.maxHeight + 25;
    }
    this.el.value = this.selectValue(this.suggestions[i]);
  },

  onSelect: function(i) {
    (this.options.onSelect || Prototype.emptyFunction)(this.suggestions[i], this.data[i]);
  },

  // added crabgrass hack: allows custom row rendering
  renderRow: function(value, re, data) {
    return (this.options.rowRenderer || Autocomplete.highlight)(value, re, data);
  },

  // added crabgrass hack: allows regexp filter of selected value
  selectValue: function(value) {
    return (this.options.selectValue ? this.options.selectValue(value) : value);
  }

};

Event.observe(document, 'dom:loaded', function(){ Autocomplete.isDomLoaded = true; }, false);
