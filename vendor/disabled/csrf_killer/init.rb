ActionView::Base.send :include, CsrfKiller::SecureForm
class << ActionController::Base
  def verify_token(options = {})
    include CsrfKiller
    before_filter :verify_request_token, :only => options.delete(:only), :except => options.delete(:except)
    verify_token_options.update(options)
  end
end