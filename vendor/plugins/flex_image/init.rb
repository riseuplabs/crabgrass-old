require 'RMagick'

require 'flex_image/controller'
require 'flex_image/model'
require 'flex_image/view'

if ActionController::Base.respond_to?(:exempt_from_layout)
  ActionController::Base.exempt_from_layout :flexi
  ActionView::Base.register_template_handler :flexi, FlexImage::View::Handler
end