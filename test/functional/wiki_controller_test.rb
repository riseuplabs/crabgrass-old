require File.dirname(__FILE__) + '/../test_helper'
require 'wiki_controller'

# Re-raise errors caught by the controller.
# class WikiController; def rescue_action(e) raise e end; end

class WikiControllerTest < ActionController::TestCase
  fixtures :groups, :pages, :users, :memberships, :sites

  def setup
    @controller = WikiController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_wiki_edit
    # just using the edit action to test the various ways to get the wiki
    group = groups(:rainbow)

    get :edit, :profile_id => group.profile, :group_id => group.id
    assert_login_required

    login_as :blue

    get :edit, :profile_id => group.profile, :group_id => group.id
    assert assigns(:public)
    assert assigns(:private)

    ## now that the above has loaded the wiki_id's for the profiles 
    ## we can test retrieving by profile id and wiki id to make sure they match
    public_wiki = assigns(:public)
    get :edit, :profile_id => group.profile, :group_id => group.id, :wiki_id => public_wiki.id
    assert assigns(:wiki)
    assert_equal assigns(:wiki), assigns(:public)
  end

end
