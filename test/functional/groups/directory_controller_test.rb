require File.dirname(__FILE__) + '/../../test_helper'

class Groups::DirectoryControllerTest < ActionController::TestCase
  fixtures :users, :groups, :memberships, :profiles, :geo_locations, :geo_countries, :geo_places

  def setup
  end

  def test_index
    get :index
    assert_redirected_to(:action => 'search')

    login_as :blue
    get :index
    assert assigns(:groups)
    assert_redirected_to(:action => 'my')

    login_as :quentin
    get :index
    assert_redirected_to(:action => 'search')    
  end

  def test_index_kml
    # non-logged in user should see  rainbow but not private_group
    get :search, :format => :kml
    assert_response :success
    assert @response.body =~ /rainbow/
    assert @response.body !~ /private/ 

    # blue should see some  kml data for rainbow
    login_as :blue
    get :search, :format => :kml
    assert_response :success
    assert @response.body =~ /Placemark/
    assert @response.body =~ /rainbow/
    assert @response.body =~ /private/
  end

  def test_recent
    login_as :blue

    get :recent, :country_id => 1
    assert assigns(:groups).include?(groups(:recent_group))

    get :recent
    assert assigns(:groups).include?(groups(:recent_group))
  end

  def test_my_groups
    groups(:warm).add_user! users(:kangaroo)
    assert !users(:kangaroo).member_of?(groups(:rainbow))

    login_as :kangaroo
    get :my
    assert_response :success
    assert_not_nil assigns(:groups)
    assert assigns(:groups).include?(groups(:warm)), 'should display committee even though it is a committee, because we are not a member of the parent'
  end

  def test_search
    # test public
    get :search, :country_id => 2
    assert assigns(:groups).include?(groups(:public_group))
    assert_response :success

    get :search
    assert assigns(:groups).include?(groups(:public_group))
    assert assigns(:group_type) == :group
    assert_response :success
  end

  def test_most_active
    login_as :blue
    get :most_active
    assert assigns(:groups).include?(groups(:true_levellers))
  end

#  def test_directory
#    login_as :gerrard
#    get :directory
#    assert_response :success
#    assert_not_nil assigns(:groups)
#  end

#  def test_directory_letter
#    login_as :blue
#    get :directory, :letter => 'r'
#    assert_response :success
#    assert_equal 1, assigns(:groups).size
#    assert_equal "rainbow", assigns(:groups)[0].name
#  end

end

