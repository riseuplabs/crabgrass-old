require File.dirname(__FILE__) + '/../test_helper'
require 'requests_controller'

# Re-raise errors caught by the controller.
class RequestsController; def rescue_action(e) raise e end; end

class RequestsControllerTest < Test::Unit::TestCase
  fixtures :users, :memberships, :groups, :profiles, :languages
#, :federatings
#, :sites, :requests

  def setup
    @controller = RequestsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_approve_and_reject_invites
    login_as :gerrard

    # generate invites
    assert_difference 'RequestToJoinUs.count', 3 do
      [:yellow, :purple, :orange].each do |user|
        RequestToJoinUs.create(
          :created_by => users(:gerrard),
          :recipient => users(user),
          :requestable => groups(:true_levellers)
        )
      end
    end

    login_as :yellow
    request = RequestToJoinUs.find(:last, :conditions => {:recipient_id => users(:yellow)})
    assert_no_difference 'RequestToJoinUs.pending.count' do
      get :reject, :id => request.id
    end

    assert_difference 'RequestToJoinUs.pending.count', -1 do
      post :reject, :id => request.id
      assert_response :redirect
    end

    login_as :purple
    request = RequestToJoinUs.find(:last, :conditions => {:recipient_id => users(:purple)})
    assert_no_difference 'Membership.count' do
      get :approve, :id => request.id
    end
    assert_difference 'Membership.count' do
      assert_difference 'RequestToJoinUs.pending.count', -1 do
        post :approve, :id => request.id
        assert_response :redirect
      end
    end

    login_as :gerrard
    request = RequestToJoinUs.find(:last, :conditions => {:recipient_id => users(:orange)})
    assert_no_difference 'RequestToJoinUs.count' do
      get :destroy, :id => request.id
    end
    assert_difference 'RequestToJoinUs.count', -1 do
      post :destroy, :id => request.id
      assert_response :redirect    
    end
  end

end
