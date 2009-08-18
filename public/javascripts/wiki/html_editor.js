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

  // returns the content area where the html lives in the dom.
  area: function() {
    return this.editor._iframe;
  },

  // returns the html text that is being edited
  content: function() {
    return this.editor.getEditorContent();
  },

  // update the html content being edited
  setContent: function(content) {
    this.editor.setEditorContent(content);
  },

  // called in case the editor needs a nudge when its panel is made visible.
  refresh: function() {
    this.editor.sizeEditor();
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

  insertImage: function(url, link) {
    if (link) {
      this.insert('<a href="#{link}"><img src="#{url}" /></a>'.interpolate({url:url,link:link}));
    } else {
      this.insert('<img src="#{url}" />'.interpolate({url:url}));
    }
  }
});

