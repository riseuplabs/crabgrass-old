$: << File.dirname(__FILE__) + '/../lib'

require 'rubygems'
gem 'activesupport', '> 2.3.0', '< 3.0'
gem 'actionpack', '> 2.3.0', '< 3.0'
require 'active_support'
require 'action_view/helpers'

require 'formy'
require 'formy/helper'

RAILS_ENV = 'developmentx'

class Testr
  include ActionView::Helpers
  include Formy::Helper

  def run
    formy(:simple_form) do |f|
      f.row do |r|
        r.label 'display name', 'user_display_name'
        r.input text_field 'user', 'display_name'
      end
      f.row do |r|
        r.label 'email address', 'user_email'
        r.input text_field 'user', 'email'
      end
    end
  end

end


puts Testr.new.run


