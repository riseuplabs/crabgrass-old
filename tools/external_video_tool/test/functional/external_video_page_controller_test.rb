require File.dirname(__FILE__) + '/../../../../test/test_helper'

class ExternalVideoPageControllerTest < ActionController::TestCase
  fixtures :pages, :users

  def setup
  end

# this controller does not really even exist yet:
  def test_create
    login_as :quentin
    num_pages = Page.count
    post :create, :id => ExternalVideoPage.param_id, :page => {:title => 'my title event' },
                    :external_video => {:media_embed => video_embed_code}

    assert_not_nil assigns(:page)
    assert_equal "hTCMcO4WTjE", assigns(:page).data.media_key
    assert_equal num_pages + 1, Page.count
  end

  def test_create_same_name
    login_as :gerrard

    data_ids, page_ids, page_urls = [],[],[]
    3.times do
      post 'create', :id => ExternalVideoPage.param_id, :page => {:title => "dupe", :summary => ""},
                      :external_video => {:media_embed => video_embed_code}
      page = assigns(:page)

      assert_equal "dupe", page.title
      assert_not_nil page.id

      # check that we have:
      # a new video
      assert !data_ids.include?(page.data.id)
      # a new page
      assert !page_ids.include?(page.id)
      # a new url
      assert !page_urls.include?(page.name_url)

      # remember the values we saw
      data_ids << page.data.id
      page_ids << page.id
      page_urls << page.name_url
    end
  end

protected
  def video_embed_code
    %q{<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/hTCMcO4WTjE&hl=en&fs=1"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/hTCMcO4WTjE&hl=en&fs=1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object>}
  end
end
