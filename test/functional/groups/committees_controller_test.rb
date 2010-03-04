require File.dirname(__FILE__) + '/../../test_helper'

class Groups::CommitteesControllerTest < ActionController::TestCase
  fixtures :groups, :users, :memberships

  include UrlHelper

  def setup
  end

  def test_create_committee_permission_denied
    parent = groups(:animals)

    login_as :gerrard
    get :new, :id => parent.to_param
    assert_permission_denied
  end

  def test_create_committee
    parent = groups(:animals)

    login_as :kangaroo
    get :new, :id => parent.to_param
    assert_response :success
    # test for #1828
    features = url_for :controller => 'groups/features',
      :action => :index, :id => parent, :only_path => true
    assert_select "a[href=#{features}]"
    committee = url_for :controller => 'groups/committees',
      :action => :new, :id => parent, :only_path => true
    assert_select "a[href=#{committee}]"

    assert_no_difference 'Committee.count' do
      post :create, :group => {:name => ''}, :id => parent.to_param
      assert_error_message
    end

    assert_no_difference 'Committee.count' do
      post :create, :group => {:name => 'marsupials'}
    end

    assert_difference 'Committee.count' do
      post :create, :group => {:name => 'marsupials'}, :id => parent.to_param
      assert_response :redirect
      group = Committee.find_by_name 'animals+marsupials'
      assert_redirected_to url_for_group(group, :action => 'edit')
    end
  end

end




