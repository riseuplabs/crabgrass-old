class CracklibController < ActionController::Base

  before_folter :set_language

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
      I18n.locale = session[:language_code].to_sym
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
   "<span class='#{klass}'>#{I18n.t(:password)} #{translated_str}</span>"
  end

end

