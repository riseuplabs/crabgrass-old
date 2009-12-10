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
    assert_equal response["suggestions"].size,
      users(:blue).friends.count + users(:blue).groups.count,
      "suggestions should contain all friends and groups."
    assert_equal response["suggestions"].size, response["data"].size,
      "there should be as many data objects as suggestions."
    assert response["suggestions"].size > 5,
      "there should be a number of preloaded suggestions for blue."
    assert_equal response["query"], '',
      "query should be empty for preloading."
  end

  def test_querying_entities
    login_as :blue
    xhr :get, :entities, :query => 'pu'
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response["suggestions"].size, response["data"].size,
      "there should be as many data objects as suggestions."
    assert response["suggestions"].size > 0,
      "there should be suggestions for blue starting with 'pu'."
    assert_equal response["query"], 'pu',
      "response.query should contain the query string."
  end

  def test_querying_entities_without_groups
    # Regression test.
    # The sql term for querying was messed up for users who
    # did not have any groups.
    login_as :quentin
    assert_equal 0, users(:quentin).groups.count,
      "quentin should not be in any groups."
    xhr :get, :entities, :query => 'an'
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response["suggestions"].size, response["data"].size,
      "there should be as many data objects as suggestions."
    assert response["suggestions"].size > 0,
      "there should be suggestions for quentin starting with 'an' -> animals."
    assert_equal response["query"], 'an',
      "response.query should contain the query string."
  end

  def test_querying_entities_without_friends
    # Regression test.
    # The sql term for querying was messed up for users who
    # did not have any friends.
    login_as :red
    assert_equal 0, users(:red).friends.count,
      "red should not have any friends."
    xhr :get, :entities, :query => 'bl'
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response["suggestions"].size, response["data"].size,
      "there should be as many data objects as suggestions."
    assert response["suggestions"].size > 0,
      "there should be suggestions for red starting with 'bl' -> blue."
    assert_equal response["query"], 'bl',
      "response.query should contain the query string."
  end
end
