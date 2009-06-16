require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
class ApplicationController; def rescue_action(e) raise e end; end

class ApplicationControllerTest < ActionController::TestCase

  def setup
    @controller = ApplicationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

#  def test_search_routes
#    assert_route "search/rainbow/archive", 
#      @controller.group_search_url(:action => 'archive', :id => 'rainbow')
#    assert_route "search/rainbow/search/type/page", 
#      @controller.group_search_url(:action => 'search', :id => 'rainbow', :path => ['type','page'])
#  end

#  def test_search_routes
#    assert_route "groups/rainbow/archive", 
#      @controller.group_search_url(:action => 'archive', :id => 'rainbow')
#    assert_route "groups/rainbow/search/type/page", 
#      @controller.group_search_url(:action => 'search', :id => 'rainbow', :path => ['type','page'])
#  end

  def test_search_routes
    assert_route "groups/search/animals/descending/updated_at",
      {:action=>"search", :id=>"animals", :path=>["descending", "updated_at"], :controller=>"groups"}

    assert_route "groups/archive/animals/type/text",
      {:action=>"archive", :id=>"animals", :path=>["type", "text"], :controller=>"groups"}
    #p url_for(:action=>"search", :id=>"animals", :path=>["descending", "updated_at"], :controller=>"groups")
  end

  def test_group_routes
    assert_route 'groups/edit/rainbow',
      {:controller => 'groups', :action => 'edit', :id => 'rainbow'}
  end

  def test_subclass_group_controller_routes
    assert_route 'groups/requests/list/rainbow',
      {:controller => 'groups/requests', :action => 'list', :id => 'rainbow'}

   assert_route 'groups/directory/my',
      {:controller => 'groups/directory', :action => 'my'}
  end

  def test_me_routes
    assert_route 'me/counts', 
      {:controller => 'me/base', :action => 'counts' }
   
    assert_route 'me/edit',
      {:controller => 'me/base', :action => 'edit' }

    #assert_route 'me/edit', @controller.me_params(:action => 'edit')
  end

  protected

  def assert_route(url, hash)
    # test hash -> url
    assert_routing url, hash

    # test url -> hash
    assert_recognizes hash, url
  end

end
