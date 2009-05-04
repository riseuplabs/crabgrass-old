class CracklibController < ActionController::Base

  around_filter :set_language

  # example params:
  #  
  #  "user"=>{"password_confirmation"=>"", "login"=>"blue", "password"=>"blue"}
  #
  def check
    check_result = Cracklib.check(params[:user][:login], params[:user][:password])
    if check_result == "OK" and params[:user][:password] != params[:user][:password_confirmation]
      check_result = Cracklib::CONFIRMATION_MISMATCH
    end
    render :text => response_span(check_result)
  end

  protected

  # an around filter responsible for setting the current language.
  def set_language
    if session[:language_code]
      Gibberish.use_language(session[:language_code]) { yield }
    else
      yield
    end
  end

  def response_span(check_result)
    code = Cracklib.translation_key_from_error_message(check_result)
    translated_str = check_result[code]
    klass = case code
      when :password_ok then 'passed'
      when :password_error_confirmation then 'info'
      else 'failed'
    end
   "<span class='#{klass}'>#{"Password".t} #{translated_str}</span>"
  end

end

