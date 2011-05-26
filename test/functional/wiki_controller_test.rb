require File.dirname(__FILE__) + '/../test_helper'

class WikiControllerTest < ActionController::TestCase
  fixtures :groups, :pages, :users, :memberships, :sites, :profiles, :wikis

# TODO: write tests for this controller
# just using the edit action to test the various ways to get the wiki

  def test_edit_requires_login
    group = groups(:rainbow)

    get :edit, :wiki_id => 300, :group_id => group.id
    assert_response :redirect
  end

  def test_edit_by_wiki_id
    group = groups(:rainbow)
    login_as :blue

    get :edit, :wiki_id => 300, :group_id => group.id   
    assert assigns(:wiki)
  end

  def test_edit_by_profile_id
    group = groups(:rainbow)
    login_as :blue
    # this actually bafflingly assigns both @public and @private 
    get :edit, :profile_id => 3, :group_id => group.id 
    
    assert_nil assigns(:wiki)
    assert assigns(:profile)
    assert assigns(:private)
    assert assigns(:public)
 
    ## now that the above has loaded the wiki_id's for the profiles are different
    ## so we can test retrieving by profile id and wiki id to make sure they match
    public_wiki = assigns(:public)
    get :edit, :profile_id => 31, :group_id => group.id, :wiki_id => public_wiki.id
    assert assigns(:wiki)
    assert_equal assigns(:wiki), assigns(:public)
  end

end
