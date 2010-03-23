require File.dirname(__FILE__) + '/../test_helper'
require 'pages_controller'
require 'pages_helper'

class PagesControllerTest < ActionController::TestCase
  fixtures :users, :pages, :user_participations

  def test_my_work
    login_as :blue
    get :my_work
    assert_response :success
    assert_no_select "a[href='/me/messages']"
  end
end
