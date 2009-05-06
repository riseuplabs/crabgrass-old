module Cracklib

  # calls cracklib_check on the password, and returns the error message (or "OK")
  # for example:
  #  cracklib_check('lincoln', 'cherrytree')
  #  => "it is based on a dictionary word"
  def self.check(login, password)
    password ||= ""
    if password =~ /#{Regexp.escape(login)}|#{Regexp.escape(login.reverse)}/
      Cracklib::BASED_ON_USERNAME
    else
      IO.popen(CRACKLIB_COMMAND, "w+") do |pipe|
        pipe.puts password
        pipe.close_write
        response = pipe.gets.chomp
        if response == "enter potential passwords, one per line..."
          response = pipe.gets.chomp
        end
        return_str = response.gsub(/^#{Regexp.escape(password)}: /,'')
        return_str = "OK" if return_str == "ok"
        return return_str
      end
    end
  end    

  BASED_ON_USERNAME = "it is based on your username"
  CONFIRMATION_MISMATCH = "it does not match password confirmation"

  CRACKLIB_STRINGS = Hash.new(:password_error_default).merge({
    "OK" => :password_ok,
    BASED_ON_USERNAME => :password_error_username,
    "it is WAY too short" => :password_error_too_short,
    "it's WAY too short" => :password_error_too_short,
    "it is too short" => :password_error_too_short,
    "it is all whitespace" => :password_error_whitespace,
    "it does not contain enough DIFFERENT characters" => :password_error_too_similar,
    "it is too simplistic/systematic" => :password_error_too_simple,
    "it is based on a dictionary word" => :password_error_too_common,
    "it is based on a (reversed) dictionary word" => :password_error_too_common,
    CONFIRMATION_MISMATCH => :password_error_confirmation
  }).freeze

  # give an error_string output from cracklib, generate a symbol that can
  # be used as a translation key for the error message.
  def self.translation_key_from_error_message(error_string)
    CRACKLIB_STRINGS[error_string]
  end

end
