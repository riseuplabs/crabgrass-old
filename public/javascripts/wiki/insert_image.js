/*
 * A plugin for Xinha to load the crabgrass specific image popup.
 * This is a replacement for the standard xinha insert image plugin.
 */

InsertImage._pluginInfo = {
  name          : "InsertImage",
  version       : "1.0",
  developer     : "riseup labs",
  developer_url : "http://labs.riseup.net",
  sponsor       : "",
  sponsor_url   : "",
  license       : "AGPL"
}

function InsertImage(editor) {
  this.editor = editor;
  editor.config.btnList.insertimage[3] = function() {
    insertImageFunction();
  };
}

