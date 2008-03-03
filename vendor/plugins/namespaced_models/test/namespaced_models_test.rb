require File.expand_path(File.dirname(__FILE__) +  '/abstract_unit')

class NamespacedModelsTest < Test::Unit::TestCase
  fixtures :people, :group_memberships, :groups
  
  set_fixture_class :group_memberships => Group::Membership
  
  def test_ensure_proper_type
    assert_equal "Group::SpecialMembership", Group::SpecialMembership.new[:type]
  end
  
  def test_find_nested_sti_from_base_class
    assert_equal Group::SpecialMembership, Group::Membership.find(2).class
  end
  
  def test_find_nested_sti_from_sti_class
    assert_equal Group::SpecialMembership, Group::SpecialMembership.find(2).class
  end
  
  def test_basic_finding
    assert_equal 2, Group::Membership.find(:all).size
    assert_equal 1, Group::SpecialMembership.find(:all).size
  end
  
  def test_find_including_namespaced_sti_classes
    group = Group.find(1, :include => [:memberships, :special_memberships])
    
    assert_equal [group_memberships(:jonathan_plonkers), group_memberships(:david_plonkers_special)], group.memberships
    assert_equal [group_memberships(:david_plonkers_special)], group.special_memberships
  end
  
  # http://dev.rubyonrails.org/ticket/9768
  def test_eager_load_has_many_through_sti_join_model
    assert_equal [people(:david)], Group.find(1, :include => :special_people).special_people
  end
  
  def test_lazy_load_has_many_through_sti_join_model
    assert_equal [people(:david)], Group.find(1).special_people
  end
end
