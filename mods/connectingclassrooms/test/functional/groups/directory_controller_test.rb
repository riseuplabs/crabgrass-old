require File.dirname(__FILE__) + '/../../test_helper'

class Groups::DirectoryControllerTest < ActionController::TestCase
  fixtures :users, :groups, :memberships, :sites, :federatings, :profiles

  def setup
    enable_site_testing :connectingclassrooms
  end

  def teardown
    disable_site_testing
  end

  def test_teacher_may_create_groups
    login_as :teacher
    get :my
    assert_response :success
    assert_not_nil assigns(:groups)
    assert_select 'div#contribute' do
      assert_select 'a[href=/groups/new]', true,
        'should display link to create a group'
    end
  end

  def test_student_may_not_create_groups
    login_as :student
    get :my
    assert_response :success
    assert_not_nil assigns(:groups)
    assert_select 'div#contribute', false
  end
end

