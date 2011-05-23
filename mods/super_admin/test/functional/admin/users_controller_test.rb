require File.dirname(__FILE__) + '/../../test_helper'

class Admin::UsersControllerTest < ActionController::TestCase

  fixtures :users, :sites, :groups, :memberships

  # none of the tests in here were written for the superadmin mod - they
  # all seemed to be a copy of the normal UserControllerTests.
  #  --azul

  def test_create_twice
    login_as :blue
    assert_difference 'User.count' do
      post_create_form
      assert_response :redirect
      assert_redirected_to({:action => :show},
        'creation should succeed.')
    end
    assert_difference 'User.count' do
      post_create_form :user => {:login => 'eriqu'}
      assert_response :redirect
      assert_redirected_to({:action => :show},
        'creating second user should be fine.')
    end
    post_create_form
    assert_response :success
    assert_select 'div.errorExplanation'
  end

  def test_create_not_matching
    login_as :blue
    post_create_form :user => {:password => 'q'}
    assert_response :success
    assert_select 'div.errorExplanation'
  end

  def test_only_superadmins
    login_as :red
    post_create_form
    assert_template 'common/permission_denied'
  end

  def test_index
    login_as :blue
    get :index, :show => 'active'
    assert (assigns[:users]).include?(:red)
    assert !(assigns[:users]).include?(:inactive_user)
  end

  protected

  def post_create_form(options = {})
    post(:create, {
      :user => {
         :login => 'quire',
         :email => 'quire@localhost',
         :password => 'quire',
         :password_confirmation => 'quire'
      }.merge(options.delete(:user) || {}),
    }.merge(options))
  end

end
