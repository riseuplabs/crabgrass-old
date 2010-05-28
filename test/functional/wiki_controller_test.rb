require File.dirname(__FILE__) + '/../test_helper'
require 'wiki_controller'

# Re-raise errors caught by the controller.
class WikiController; def rescue_action(e) raise e end; end

class WikiControllerTest < ActionController::TestCase
  fixtures :groups, :pages, :users, :memberships, :sites

  def setup
    @controller = WikiController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

# TODO: write tests for this controller

  def test_before_filters
    # just using the edit action to test the various ways to get the wiki
    group = groups(:rainbow)

    get :edit, :wiki_id => 300, :group_id => group.id
    assert_response :redirect

    login_as :blue

    get :edit, :wiki_id => 300, :group_id => group.id
    assert assigns(:wiki)

    # this actually bafflingly assigns both @public and @private
    get :edit, :profile_id => 3, :group_id => group.id
    assert assigns(:wiki) ## i don't really understand how @wiki is getting assigned here?!?!?!
    assert assigns(:profile)
    assert assigns(:private)
    assert assigns(:public)
    assert_equal assigns(:wiki), assigns(:public)

    ## now that the above has loaded the wiki_id's for the profiles are different
    ## so we can test retrieving by profile id and wiki id to make sure they match
    public_wiki = assigns(:public)
    get :edit, :profile_id => 31, :group_id => group.id, :wiki_id => public_wiki.id
    assert assigns(:wiki)
    assert_equal assigns(:wiki), assigns(:public)
  end

end
