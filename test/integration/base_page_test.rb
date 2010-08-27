require "#{File.dirname(__FILE__)}/../test_helper"

class BasePageTest < ActionController::IntegrationTest

  # i am not sure what this test is trying to do.
  # the post doesn't appear to actually modify the access at all. 
  # maybe this made more sense when 'share with all' was a feature.
  # i guess maybe share with all is coming back. for now, this
  # doesn't work. -elijah
  def xtest_share_with_all
    with_site :unlimited do
      host! 'test.host'
      login :blue
      assert_not_nil page = Page.find(214), "Could not find page."
      assert_not_nil site = Site.current, "Could not find site."
      assert_not_nil group = site.network, "Could not find site network."
      get '/blue/survey-ipsum+214'
      assert_response :success, "Could not get page."
      # share with all has been disabled as of #1672
      assert_select "li#share_all_li", false
      assert page.participation_for_group(group).nil?, "Page has already been shared with all."
      post '/base_page/participation/update_share_all?add=true&page_id=214'
      page.reload
      assert !page.participation_for_group(group).nil?, "Page does not have participation after sharing."
      login :red
      get '/blue/survey-ipsum+214', "can't display page as a different user!"
      login :blue
      get '/blue/survey-ipsum+214'
      assert_select "a[href='/#{group.name}']"
      get '/base_page/participation/update_share_all?page_id=214'
      page.reload
      assert page.participation_for_group(group).nil?, "Page still has participation after unsharing."
    end
  end

  def test_no_share_with_all
    host! 'test.host'
    login :blue
    assert_not_nil page = Page.find(214), "Could not find page."
    assert_not_nil site = Site.current, "Could not find site."
    assert_nil group = site.network, "Could not find site network."
    get '/blue/survey-ipsum+214'
    assert_response :success, "Could not get page."
      # share with all has been disabled as of #1672
    assert_select "li#share_all_li", false
  end
end
