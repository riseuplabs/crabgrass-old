require File.dirname(__FILE__) + '/../test_helper'

class DiscussionPageControllerTest < ActionController::TestCase

  fixtures :users, :sites, :groups, :memberships, :federatings, :pages, :user_participations, :group_participations

  def setup
    enable_site_testing('connectingclassrooms')
  end

  def teardown
   disable_site_testing
  end

  def test_teacher_may_view_student_pages
    login_as :teacher
    # page 1087 only belongs to student.
    get :show, :page_id=>1087
    assert_response :success, 'teacher should be allowed to see students private pages'
  end

  def test_student_may_not_view_others_pages
    login_as :student
    # page 1098 only belongs to visitor and the second clas
    get :show, :page_id=>1098
    assert_response :success
    assert_select 'blockquote', 'Sorry. You do not have the ability to perform that action.', 'student should not see visitors private pages / pages of class2'
  end

end

