if RAILS_ENV != 'production'
  # annotate partials in html
  class ActionController::Base
    include PartialExposure
  end
end