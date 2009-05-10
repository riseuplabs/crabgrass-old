require File.dirname(__FILE__) + '/../../test_helper'
require 'ranked_vote_page_controller'

# Re-raise errors caught by the controller.
class RankedVotePageController; def rescue_action(e) raise e end; end

class Tool::RankedVotePageControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :user_participations, :polls, :possibles

  def setup
    @controller = RankedVotePageController.new
    @request    = ActionController::TestRequest.new
    @request.host = "localhost"
    @response   = ActionController::TestResponse.new

    login_as :orange
    get :create, :id => RankedVotePage.param_id
  end

  def test_create_show_add_and_show
    assert_no_difference 'Page.count' do
      get :create, :id => RankedVotePage.param_id
      assert_response :success
#      assert_template 'base_page/create'
    end
  
    assert_difference 'RankedVotePage.count' do
      post :create, :id => RankedVotePage.param_id, :page => {:title => 'test title'}
      assert_response :redirect
    end
    
    p = Page.find(:all)[-1] # most recently created page (?)
    get :show, :page_id => p.id
    assert_response :redirect
    assert_redirected_to @controller.page_url(assigns(:page), :action => 'edit') # redirect to edit since no possibles
    
    assert_difference 'p.data.possibles.count' do
      post :add_possible, :page_id => p.id, :possible => {:name => "new option", :description => ""}
    end

    get :show, :page_id => p.id
    assert_response :success
#    assert_template 'ranked_vote_page/show'
  end
  
  # TODO: tests for sort, update_possible, edit_possible, destroy_possible,
end
