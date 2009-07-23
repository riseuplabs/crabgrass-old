require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users, :sites, :groups, :memberships, :federatings
 
  def setup
    Conf.enable_site_testing
  end

  def test_mixin_is_working
    assert users(:blue).respond_to?(:coordinator_of?), 'the student user mixin should be applied'
  end

  def test_group_setup
    assert Site.first.council == groups(:teachers), 'teachers group should be site council'
  end

  def test_student_id_cache
    for u in [:student, :teacher, :visitor, :other_student, :other_teacher, :other_visitor] do
      assert users(u).update_membership_cache, 'updating membership_cache failed'
      # all teachers have students, only teachers have students
      assert users(u).member_of?(groups(:teachers)) != users(u).student_id_cache.empty?, 'teachers should have students, non-teachers should not.' 
    end
    assert users(:teacher).student_id_cache = [101, 103]
    assert users(:other_teacher).student_id_cache = [101, 102, 103, 104, 106]
    groups(:class1).remove_user!(users(:visitor))
    groups(:class2).remove_user!(users(:other_visitor))
    assert users(:teacher).student_id_cache = [101]
    assert users(:other_teacher).student_id_cache = [101, 102, 103, 106]
    assert users(:teacher).coordinator_of?(users(:student))
    assert !users(:teacher).coordinator_of?(users(:other_student))
  end

  def test_students_of_user
    for u in [:teacher, :other_teacher] do
      assert_equal users(u).students.collect{|s| s.login}.sort,
        User.students_of(users(u)).collect{|s| s.login}.sort, 'teacher.students and User.students_of(teacher) should be the same.'
    end
  end
end

