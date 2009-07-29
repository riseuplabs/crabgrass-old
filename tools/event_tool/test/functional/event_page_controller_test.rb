require File.dirname(__FILE__) + '/../../../../test/test_helper'

class EventPageControllerTest < ActionController::TestCase
  fixtures :pages, :users

  def setup
  end

# this controller does not really even exist yet:
  def test_create
    login_as :quentin
    num_pages = Page.count
    post :create, :id => EventPage.param_id, :page => {:title => 'my title event' },
                    :event => {"is_all_day"=>"1", "location"=>"right here, right now"}, "date_start"=>"28/5/2009"

    assert_not_nil assigns(:page)
    assert_equal "right here, right now", assigns(:page).data.location
    assert_equal num_pages + 1, Page.count
  end

  def test_create_same_name
    login_as :gerrard

    data_ids, page_ids, page_urls = [],[],[]
    3.times do
      post 'create', :id => EventPage.param_id, :page => {:title => "dupe", :summary => ""},
                      :event => {"is_all_day"=>"1", "location"=>"right here, right now"}, "date_start"=>"28/5/2009"
      page = assigns(:page)

      assert_equal "dupe", page.title
      assert_not_nil page.id

      # check that we:
      # have a new data
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

=begin

  def test_get_create
    login_as :quentin
    get :create, {:action => "create", "id"=>"event", "controller"=>"event_page"}
    assert_response :success
    assert assigns(:event)
    assert assigns(:page_class)
    assert assigns(:event).new_record?
  end

  def test_create_login_required
    get :create, {:action => "create", "id"=>"event", "controller"=>"event_page"}
    assert_response 302
  end


=end
end
