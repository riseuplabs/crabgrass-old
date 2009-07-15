require File.dirname(__FILE__) + '/../test_helper'
require 'autocomplete_controller'

# Re-raise errors caught by the controller.
class AutocompleteController; def rescue_action(e) raise e end; end

class AutocompleteControllerTest < Test::Unit::TestCase
  fixtures :users, :groups,
          :memberships, :user_participations, :group_participations,
          :pages, :profiles, :relationships

  def setup
    @controller = AutocompleteController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_preloading_entities
    login_as :blue
    xhr :get, :entities, :query => ''
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response["suggestions"].count,
      users(:blue).friends.count + users(:blue).groups.count,
      "suggestions should contain all friends and groups."
    assert_equal response["suggestions"].count, response["data"].count,
      "there should be as many data objects as suggestions."
    assert response["suggestions"].count > 5,
      "there should be a number of preloaded suggestions for blue."
    assert_equal response["query"], '',
      "query should be empty for preloading."
  end

  def test_querying_entities
    login_as :blue
    xhr :get, :entities, :query => 'pu'
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response["suggestions"].count, response["data"].count,
      "there should be as many data objects as suggestions."
    assert response["suggestions"].count > 0,
      "there should be suggestions for blue starting with 'pu'."
    assert_equal response["query"], 'pu',
      "response.query should contain the query string."
  end
end
