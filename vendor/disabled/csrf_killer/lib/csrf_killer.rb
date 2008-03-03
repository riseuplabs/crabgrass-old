require 'openssl'
# Protect a controller's actions with the #verify_token method.  Failure to validate will result in a CsrfKiller::InvalidToken 
# exception.  Customize the error message through the use of rescue_templates and rescue_action_in_public.
#
#   class FooController < ApplicationController
#     # uses the cookie session store
#     verify_token :except => :index
#
#     # uses one of the other session stores that uses a session_id value.
#     verify_token :secret => 'my-little-pony', :except => :index
#   end
#
# Valid Options:
#
# * <tt>:only/:except</tt> - passed to the before_filter call.  Set which actions are verified.
# * <tt>:secret</tt> - Custom salt used to generate the form_token.  Leave this off if you are using the cookie session store.
# * <tt>:digest</tt> - Message digest used for hashing.  Defaults to 'SHA1'
module CsrfKiller
  class InvalidToken < StandardError; end

  # Adds a token_tag to every form tag.
  module SecureForm
    def self.included(base)
      base.alias_method_chain :extra_tags_for_form, :security
      base.alias_method_chain :options_for_ajax,    :security
    end
    
    # Creates the actual hidden tag for the token value
    def token_tag
      content_tag(:div, tag(:input, :type => "hidden", :name => "_token", :value => form_token), :style => 'margin:0;padding:0')
    end
    
    # Adds the _token to the :with option of #options_for_ajax unless :with is already used.
    def options_for_ajax_with_security(options)
      token_param = "_token=' + encodeURIComponent('#{escape_javascript form_token}')"
      if options[:with]
        options[:with] << " + '&" << token_param
      else
        options[:with] = "'" << token_param
      end
      options_for_ajax_without_security(options)
    end
    
    private
      def extra_tags_for_form_with_security(html_options)
        returning extra_tags_for_form_without_security(html_options) do |tags|
          tags << token_tag unless html_options['method'].to_s =~ /^get$/i
        end
      end
  end

  def self.included(base)
    base.class_inheritable_accessor :verify_token_options
    base.verify_token_options   = {}
    base.rescue_responses['CsrfKiller::InvalidToken'] = :unprocessable_entity
    base.helper_method :form_token
  end

  protected
    # The actual before_filter that is used.  Modify this to change how you handle unverified requests.
    def verify_request_token
      verified_request? || raise(CsrfKiller::InvalidToken)
    end
    
    # Returns true or false if a request is verified.  Checks:
    #
    # * is the format restricted?  By default, only HTML and AJAX requests are checked.
    # * is it a GET request?  Gets should be safe and idempotent
    # * Does the form_token match the given _token value from the params?
    def verified_request?
      !verifiable_request_format? || (request.method == :get || form_token == params[:_token])
    end

    def verifiable_request_format?
      request.format.html? || request.format.js?
    end

    # Sets the token value for the current session.  Pass a :secret option in #verify_token to add a custom salt to the hash.
    def form_token
      @form_token ||= verify_token_options[:secret] ? token_from_session_id : token_from_cookie_session
    end
    
    # Generates a unique digest using the session_id and the CSRF secret.
    def token_from_session_id
      key    = verify_token_options[:secret].respond_to?(:call) ? verify_token_options[:secret].call(@session) : verify_token_options[:secret]
      digest = verify_token_options[:digest] || 'SHA1'
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new(digest), key, session.session_id)
    end
    
    # No secret was given, so assume this is a cookie session store.
    def token_from_cookie_session
      session[:csrf_id] ||= CGI::Session.generate_unique_id
      session.dbman.generate_digest(session[:csrf_id])
    end
end