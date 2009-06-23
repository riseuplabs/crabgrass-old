require File.dirname(__FILE__) + '/../test_helper'
require 'groups_controller'
#showlog
# Re-raise errors caught by the controller.
class GroupsController; def rescue_action(e) raise e end; end

class GroupsControllerTest < Test::Unit::TestCase
  fixtures :groups, :group_settings, :users, :memberships, :profiles, :pages,
            :group_participations, :user_participations, :tasks, :page_terms, :sites,
            :federatings

  include UrlHelper

  def setup
    @controller = GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def teardown
   disable_site_testing
  end

  def test_show_as_teacher
    login_as :teacher

    # show a group you belong to
    get :show, :id => groups(:class1).name
    assert_response :success
#    assert_template 'show'

    assert_not_nil assigns(:group)
    assert assigns(:group).valid?
    class1=assigns(:group)
    # testing access rights
    assert_not_nil assigns(:access)
    assert_equal :private, assigns(:access), "teacher should have access to private group information for class1"
    # testing link display
    assert_select 'ul.side_list' do |ul|
      # this one should check for contributions
      # how ever none of the following seem to 
      # work - will check back later TODO
      # assert_select 'li.group_contributions_16'
      # assert_select 'li.small_icon.group_contributions_16'
      # assert_select 'a', "Contributions"
    end


    #show the teachers council you belong to
    get :show, :id => groups(:class1_teachers).name
    assert_response :success
    assert assigns(:group).valid?
    class1_council=assigns(:group)
    assert_equal class1.council_id, class1_council.id
  end

  def test_contributions_view_teacher
    login_as :teacher
    users(:teacher).update_membership_cache
    debugger
    page_ids = get_contributions_page_ids
    # pages that have only been touched by student
    # so they would be private without the student mod
    # teacher should see them never the less
    assert page_ids.include?(1003)
    assert page_ids.include?(1007)
  end

  def test_contributions_view_student
    login_as :student
    page_ids = get_contributions_page_ids
    # pages that have only been touched by student
    # so they would be private without the student mod
    # student should always see her/his own pages
    assert page_ids.include?(1003)
    assert page_ids.include?(1007)
  end

  def test_contributions_view_visitor
    login_as :visitor
    page_ids = get_contributions_page_ids
    # pages that have only been touched by student
    # so they would be private without the student mod
    # visitors should never see them.
    assert !page_ids.include?(1003)
    assert !page_ids.include?(1007)
  end

  def get_contributions_page_ids
    get :contributions, :id => groups(:class1).name
    assert_response :success
    assert assigns(:pages)
    pages = assigns(:pages)
    pages.collect{|p|p.id}.sort
  end
end
