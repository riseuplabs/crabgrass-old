require File.dirname(__FILE__) + '/../../../../test/test_helper'
require 'wiki_page_version_controller'

# Re-raise errors caught by the controller.
class WikiPageVersionController; def rescue_action(e) raise e end; end

class WikiPageVersionControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :user_participations, :wikis, :groups, :sites

  def setup
    @controller = WikiPageVersionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    HTMLDiff.log_to_stdout = false # set to true for debugging
  end

  def test_version_show
    login_as :orange
    pages(:wiki).add groups(:rainbow), :access => :edit

    # create versions
    (1..5).zip([:orange, :yellow, :blue, :red, :purple]).each do |i, user|
      login_as user
      pages(:wiki).data.update_document!(users(user), i, "text %d for the wiki" % i)
    end

    # create another modification by the last user
    # should not create a new version
    pages(:wiki).data.update_document!(users(:purple), 6, "text 6 for the wiki")

    login_as :orange
    pages(:wiki).data.versions.reload

    # find versions
    (1..5).each do |i|
      get :show, :page_id => pages(:wiki).id, :id => i
      assert_response :success
      assert_equal i, assigns(:version).version
    end

    # should fail gracefully for non-existant version
    get :show, :page_id => pages(:wiki).id, :id => 6
    assert_response :success
    assert_nil assigns(:version)
  end

  def test_diff
    login_as :orange

    (1..5).zip([:orange, :yellow, :blue, :red, :purple]).each do |i, user|
      pages(:wiki).data.update_document!(users(user), i, "text %d for the wiki" % i)
    end

    post :diff, :page_id => pages(:wiki).id, :id => "4-5"
    assert_response :success

    assert_equal assigns(:wiki).versions.reload.find_by_version(4).body_html, assigns(:old_markup)
    assert_equal assigns(:wiki).versions.reload.find_by_version(5).body_html, assigns(:new_markup)
    assert assigns(:difftext).length > 10, "difftext should contain something substantial"
  end

  def test_revert
    login_as :orange
    pages(:wiki).data.update_document!(users(:blue), 1, "version 1")
    pages(:wiki).data.update_document!(users(:yellow), 2, "version 2")
    post :revert, :page_id => pages(:wiki).id, :id => 1

    wiki = Wiki.find(pages(:wiki).data.id)

    assert_redirected_to @controller.page_url(assigns(:page), :action => 'show'), "revert should redirect to show wiki action"
    assert_equal "version 1", wiki.body
  end

end
