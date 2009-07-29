require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/custom_appearances_controller'

# Re-raise errors caught by the controller.
class Admin::CustomAppearancesController; def rescue_action(e) raise e end; end

class Admin::CustomAppearancesControllerTest < ActionController::TestCase

  fixtures :users, :sites, :groups, :memberships, :pages

  def setup
    enable_site_testing('unlimited')
    @current_site=Site.current
  end

  def teardown
    disable_site_testing
  end

  def test_no_admin
    login_as :red
    assert_no_access "only site admins may access the actions."
  end

  def test_no_site
    disable_site_testing
    login_as :penguin
    assert_no_access "none of the CustomAppearances actions should be enabled without sites."
  end

  # first call to new should generate custom_appearance.
  # later calls should return the same custom appearance.
  def test_new
    login_as :penguin
    assert_nil @current_site.custom_appearance
    get :new
    @current_site.reload
    assert_not_nil custom_appearance=@current_site.custom_appearance
    assert_response :redirect
    assert_redirected_to edit_admin_custom_appearance_url(custom_appearance)
    get :new
    @current_site.reload
    assert_equal custom_appearance, @current_site.custom_appearance
    assert_response :redirect
    assert_redirected_to edit_admin_custom_appearance_url(custom_appearance)
  end

  def test_update
    init_custom_appearance
    login_as :penguin
    post :update, :id => @current_site.custom_appearance.id,
      :custom_appearance => {:parameters => {}}
    assert_not_nil appearance=assigns(:appearance)
    assert_equal({}, appearance.parameters)
    assert_response :redirect
    assert_redirected_to :action => 'edit'
    post :update, :id => @current_site.custom_appearance.id,
      :custom_appearance => {:parameters => {:bla=>""}}
    assert_not_nil appearance=assigns(:appearance)
    # symbols in the keys are converted to strings.
    assert_equal({"bla"=>""}, appearance.parameters)
  end

  def test_edit_and_available
    init_custom_appearance
    login_as :penguin
    get :edit, :id => @current_site.custom_appearance.id
    assert_response :success
    get :available, :id => @current_site.custom_appearance.id
    assert_response :success
  end

  def assert_no_access(message="")
    # Currently this assertion crashes for no_site and it gives a
    # irritating error message.
    # this should be prohibided by permissions if we have no site instead.
    get :new
    assert_response :redirect, message
    assert_redirected_to({:controller => 'account', :action => 'login'}, message)
    init_custom_appearance
    get :edit, :id => @current_site.custom_appearance.id
    assert_response :redirect, message
    assert_redirected_to({:controller => 'account', :action => 'login'}, message)
    post :update, :id => @current_site.custom_appearance.id
    assert_response :redirect, message
    assert_redirected_to({:controller => 'account', :action => 'login'}, message)
    get :available, :id => @current_site.custom_appearance.id
    assert_response :redirect, message
    assert_redirected_to({:controller => 'account', :action => 'login'}, message)
  end

  def init_custom_appearance()
    @current_site.create_custom_appearance
    @current_site.save
  end
end
