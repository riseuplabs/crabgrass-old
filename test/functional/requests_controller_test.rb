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

  def test_accept_error_bad_code
    #url = "http://localhost:3000/invites/accept/bad-code/root_at_localhost"

    get :accept, :path => ['bad-code', 'root_at_localhost']
    assert_response :not_found
    assert_error_message
  end

  def test_accept_error_already_redeemed
    req = RequestToJoinUsViaEmail.create(
      :created_by => users(:dolphin),
      :email => 'root@localhost',
      :requestable => groups(:animals),
      :language => languages(:pt)
    )
    request = RequestToJoinUsViaEmail.redeem_code!(users(:red), req.code, req.email)
    request.approve_by!(users(:red))

    #url = "http://localhost:3000/invites/accept/#{req.code}/root_at_localhost"

    get :accept, :path => [req.code, 'root_at_localhost']
    assert_response :success
    assert_error_message(/#{Regexp.escape(I18n.t(:invite_error_redeemed))}/)
  end

  def test_redeem_error
    login_as :blue

    get :redeem, :email => 'bogus', :code => 'bogus'
    assert_response :not_found
    assert_error_message
  end

  def test_already_redeemed_error
    req = RequestToJoinUsViaEmail.create(
      :created_by => users(:dolphin),
      :email => 'root@localhost',
      :requestable => groups(:animals),
      :language => languages(:pt)
    )
    request = RequestToJoinUsViaEmail.redeem_code!(users(:red), req.code, req.email)
    request.approve_by!(users(:red))

    login_as :red
    get :redeem, :email => req.email, :code => req.code
    assert_response :success
    assert I18n.t(:invite_error_redeemed).any?
    assert_error_message(/#{Regexp.escape(I18n.t(:invite_error_redeemed))}/)
  end

  def test_already_member_error
    req = RequestToJoinUsViaEmail.create(
      :created_by => users(:dolphin),
      :email => 'root@localhost',
      :requestable => groups(:animals),
      :language => languages(:pt)
    )

    login_as :penguin
    get :redeem, :email => req.email, :code => req.code
    assert I18n.t(:invite_error_already_member).any?
    assert_response :success
    assert_error_message(/#{Regexp.escape(I18n.t(:invite_error_already_member))}/)
  end

end
