class GalleryController < BasePageController

  javascript :swfobject, :only => [:edit, :show]
  javascript :audio, :only => [:edit, :show]

end
