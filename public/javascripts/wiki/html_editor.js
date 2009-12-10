//
// HtmlEditor: a wysiwyg class wrapper.
//
// This class abstracts away the specific calls to particular wysiwyg html
// editors so that we can change editors without changing too much code.
//

var HtmlEditor = Class.create({

  // create the wrapper using the wiki id
  initialize: function(wiki_id) {
    this.editor = Xinha.getEditor("wiki_body_html-" + wiki_id);
  },

  // return true if the editor was actually found.
  valid: function() {
    return this.editor;
  },

  // called in case the editor needs a nudge when its panel is made visible.
  refresh: function() {
    this.editor.sizeEditor();
    this.editor.activateEditor();
    this.editor.focusEditor();
  },

  // returns the content area where the html lives in the dom.
  area: function() {
    return this.editor._iframe;
  },

  // returns the html text that is being edited
  content: function() {
    return this.editor.getEditorContent();
  },

  // get the currently selected HTML
  selectedContent: function() {
    return this.editor.getSelectedHTML();
  },

  // returns the currently selected <a> element, if there are any.
  selectedAnchor: function() {
    var ret  = null;
    var sel  = this.editor.getSelection();
    var rng  = this.editor.createRange(sel);
    var a    = this.editor.activeElement(sel);
    if (a != null && a.tagName.toLowerCase() == 'a') {
      ret = a;
    } else {
      a = this.editor._getFirstAncestor(sel, 'a');
      if (a != null) {
        ret = a;
      }
    }
    if (ret) {
      ret.setAttribute('href', this.relativeHref(ret.getAttribute('href')));
      return ret;
    } else {
      return null;
    }
  },

  // returns a relative href. This is needed because IE this returns a horrible mess.
  relativeHref: function(href) {
    // return this.editor.fixRelativeLinks(this.selectedAnchor().getAttribute('href'));
    var serverBase = location.href.replace(/(https?:\/\/[^\/]*)\/.*/, '$1') + '/';
    return href.replace(serverBase, '');
  },

  saveSelection: function() {
    current_editor_range = this.editor.saveSelection();
  },

  restoreSelection: function() {
    this.editor.restoreSelection(current_editor_range);
  },

  // update the html content being edited
  setContent: function(content) {
    this.editor.setEditorContent(content);
  },

  // run execCommand on the html area.
  // see: http://www.mozilla.org/editor/midas-spec.html
  //      http://msdn.microsoft.com/workshop/author/dhtml/reference/methods/execcommand.asp
  execCommand: function(cmd,param) {
    this.editor.execCommand(cmd, false, param);
  },

  // insert some raw html into the content at the cursor
  insert: function(html) {
    this.editor.insertHTML(html);
  },

  // inserts an new image tag
  insertImage: function(url, link) {
    if (link) {
      this.insert('<a href="#{link}"><img src="#{url}" /></a>'.interpolate({url:url,link:link}));
    } else {
      this.insert('<img src="#{url}" />'.interpolate({url:url}));
    }
  },

  // inserts a new anchor tag or updates an existing anchor tag (if one is selected)
  insertAnchor: function(label, href) {
    var anchor = this.selectedAnchor();
    if (anchor) {
      anchor.href = href;
      anchor.innerHTML = label;
    } else if (label) {
      this.insert('<a href="#{href}">#{label}</a>'.interpolate({href:href,label:label}));
    }
  },

  // removes an anchor tag from the selection.
  clearAnchor: function() {
    var a = this.selectedAnchor();
    var p = a.parentNode;
    while(a.hasChildNodes()) {
      p.insertBefore(a.removeChild(a.childNodes[0]), a);
    }
    p.removeChild(a);
    this.editor.updateToolbar();
  }

});

