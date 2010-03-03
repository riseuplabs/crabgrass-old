require File.dirname(__FILE__) + '/../../test_helper'
require 'me/requests_controller'

class Me::RequestsControllerTest < ActionController::TestCase
  fixtures :groups, :users, :memberships, :requests

  # TODO: Add fixtures for requests to make results in all of these categories

  def test_index
    login_as :blue
    %w/all from_me to_me/.each do |view|
      get :index, :view => view
      assert_response :success
    end
  end

  def test_approved
    login_as :blue
    %w/all from_me to_me/.each do |view|
      get :approved, :view => view
      assert_response :success
    end
  end

  def test_rejected
    login_as :blue
    %w/all from_me to_me/.each do |view|
      get :rejected, :view => view
      assert_response :success
    end
  end

end
