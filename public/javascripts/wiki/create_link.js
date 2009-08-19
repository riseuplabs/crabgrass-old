/*
 * A plugin for Xinha to load the crabgrass specific link popup.
 * This is a replacement for the standard xinha create link plugin.
 */

CreateLink._pluginInfo = {
  name          : "CreateLink",
  version       : "1.0"
}

function CreateLink(editor) {
  editor.config.btnList.createlink[3] = function() {
    createLinkFunction();
  };
}

