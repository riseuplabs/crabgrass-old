require File.dirname(__FILE__) + '/../../test_helper'
require 'rate_many_page_controller'

# Re-raise errors caught by the controller.
class RateManyPageController; def rescue_action(e) raise e end; end

class Tool::RateManyPageControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :user_participations, :polls, :possibles

  def setup
    @controller = RateManyPageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_all

    login_as :orange

    assert_no_difference 'Page.count' do
      get :create, :id => RateManyPage.class_display_name
      assert_template 'base_page/create'
    end
  
    assert_difference 'RateManyPage.count' do
      post :create, :id => RateManyPage.class_display_name, :page => {:title => 'test title'}
      assert_response :redirect
    end
    
    p = Page.find(:all)[-1] # most recently created page (?)
    get :show, :page_id => p.id
    assert_response :success
    assert_template 'rate_many_page/show'
    
    assert_difference 'p.data.possibles.count' do
      post :add_possible, :page_id => p.id, :possible => {:name => "new option", :description => ""}
    end
    assert_not_nil assigns(:possible)

    assert_difference 'p.data.possibles.count', -1 do
      post :destroy_possible, :page_id => p.id, :possible => assigns(:possible).id

    end
    
    post :add_possible, :page_id => p.id, :possible => {:name => "new option", :description => ""}
    id = assigns(:possible).id
    post :vote_one, :page_id => p.id, :id => id, :value => "2"
    assert_equal 2, PollPossible.find(id).votes.find(:all).find { |p| p.user = users(:orange) }.value
  end
  
  # TODO: tests for vote, clear votes, sort
end
