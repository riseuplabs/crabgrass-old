require File.dirname(__FILE__) + '/../../../../test/test_helper'

class GalleryControllerTest < ActionController::TestCase
  fixtures :pages, :users

  def setup
  end

# this controller does not really even exist yet:
  def test_create
    login_as :quentin
    num_pages = Page.count
    post :create, :page_type => "Gallery", :page => {:title => 'picatures' }, :id => Gallery.param_id

    assert_not_nil assigns(:page)
    assert_equal "picatures", assigns(:page).title
    assert_equal num_pages + 1, Page.count
  end

  def test_create_same_name
    login_as :gerrard

    data_ids, page_ids, page_urls = [],[],[]
    3.times do
      post 'create', :page => {:title => "dupe", :summary => ""}, :id => Gallery.param_id
      page = assigns(:page)

      assert_equal "dupe", page.title
      assert_not_nil page.id

      # check that we have:
      # a new page
      assert !page_ids.include?(page.id)
      # a new url
      assert !page_urls.include?(page.name_url)

      # remember the values we saw
      page_ids << page.id
      page_urls << page.name_url
    end
  end
end
