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
    simple_form = formy(:simple_form) do |f|
      f.row do |r|
        r.label 'display name', 'user_display_name'
        r.input text_field 'user', 'display_name'
      end
      f.row do |r|
        r.label 'email address', 'user_email'
        r.input text_field 'user', 'email'
      end
    end
    tabset = formy(:tabset) do |f|
      f.tab do |t|
        t.label 'Tab One'
        t.show_tab 'tab-one-div'
        t.selected true
      end
      f.tab do |t|
        t.label 'Tab Two'
        t.show_tab 'tab-two-div'
        t.selected false
      end
    end
    simple_form + tabset
  end

end


puts Testr.new.run


