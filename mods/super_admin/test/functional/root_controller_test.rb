require File.dirname(__FILE__) + '/../test_helper'
require 'root_controller'
class RootController; def rescue_action(e) raise e end; end

class RootControllerTest < Test::Unit::TestCase
  fixtures :groups, :users, :pages, :memberships,
            :user_participations, :page_terms, :sites

  include UrlHelper

  def setup
    @controller = RootController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_site_home
    enable_site_testing :test do
      login_as :red
      get :index
      assert_response :success
      assert User.inactive_user_ids
      assert_nil assigns["users"].detect{|u|
        User.inactive_user_ids.include?(u.id)
      }, "There should be no inactive users in the list"
    end
  end

end
