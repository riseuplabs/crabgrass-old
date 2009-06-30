require File.dirname(__FILE__) + '/../../test_helper'
require 'base_page/title_controller'

# Re-raise errors caught by the controller.
class BasePage::TitleController; def rescue_action(e) raise e end; end

class BasePage::TitleControllerTest < Test::Unit::TestCase
  fixtures :users, :groups,
           :memberships, :user_participations, :group_participations,
           :pages, :profiles,
           :taggings, :tags

  def setup
    @controller = BasePage::TitleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end


  def test_edit
    login_as(:red)
    post :edit, :page_id => 1, :page => {:title => "new title"}, :save => 'Save pressed'
    assert_response :success
  end

  def test_update
    login_as(:red)
    post :update, :page_id => 1, :page => {:title => "new title", :summary => "new summary", :name => "new-name"}, :save => 'Save pressed'
    assert_equal "new title", Page.find(1).title
    assert_equal "new summary", Page.find(1).summary
    assert_equal "new-name", Page.find(1).name
  end

  def test_update_name
    login_as(:blue)
    page = Page.find(42)
    assert groups(:rainbow).may?(:admin, page)
    assert page.groups.include? groups(:rainbow)

    assert_equal 42, groups(:rainbow).pages.find_by_id(42).id

    post :update, :page_id => 42, :page => {:name => 'a shoe horn with teeth', :title => page.title}, :save => true

    assert_equal 42, groups(:rainbow).pages.find_by_name('a-shoe-horn-with-teeth').id
  end

end
