require File.dirname(__FILE__) + '/../test_helper'
require 'discussion_page_controller'

# Re-raise errors caught by the controller.
class DiscussionPageController; def rescue_action(e) raise e end; end

class DiscussionPageControllerTest < ActionController::TestCase

  fixtures :users, :sites, :groups, :memberships, :federatings, :pages, :user_participations, :group_participations

  def setup
    @controller = DiscussionPageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
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
    assert_response :redirect, 'student should not see visitors private pages / pages of class2'
  end

end

