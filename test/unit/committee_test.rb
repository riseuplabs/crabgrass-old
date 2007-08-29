require File.dirname(__FILE__) + '/../test_helper'

class CommitteeTest < Test::Unit::TestCase
  fixtures :groups, :users

  def setup
    #@group = groups[:rainbow]
    #@c1 = groups[:warm]
    #@c2 = groups[:cold]
  end
  
  def test_creation_and_deletion
    g = Group.create :name => 'riseup'
    c1 = Committee.create :name => 'finance'
    c2 = Committee.create :name => 'food'
    g.committees << c1
    g.committees << c2
    g.reload
    assert_equal 2, g.committees.count, 'there should be two committees'
    assert_equal g, c1.parent, "committee's parent should match group"
    c1.destroy
    assert_equal 1, g.committees.count, 'now there should be one committee'
    g.destroy
    assert_nil Committee.find_by_name('food'), 'committee should die with group'
  end

  def test_membership
    g = Group.create :name => 'riseup'
    c1 = Committee.create :name => 'finance'
    c2 = Committee.create :name => 'food'
    g.committees << c1
    g.committees << c2
    u = users(:kangaroo)
    
   
    assert(!u.member_of?(g), 'user should not be member yet')
    u.memberships.create :group => g

    assert u.member_of?(g), 'user should be member of group'
    assert u.member_of?(c1), 'user should also be a member of committee'
    assert(u.direct_member_of?(g), 'user should be a direct member of the group')
    assert(!u.direct_member_of?(c1), 'user should not be a direct member of the committee')
    u.groups.delete(g)

    assert(!u.member_of?(g), 'user should not be member of group after being removed')
    assert(!u.member_of?(c1), 'user should not be a member of committee')
               
  end
  
  def test_naming
    g = Group.create :name => 'riseup'
    c = Committee.new :name => 'outreach'
    c.parent = g
    c.save
    assert_equal 'riseup+outreach', c.full_name, 'committee full name should be in the form <groupname>+<committeename>'
    c.name = 'legal'
    c.save
    assert_equal 'riseup+legal', c.full_name, 'committee name update when changed.'
    g.reload
    g.name = 'riseup-collective'
    g.save
    assert_equal 'riseup-collective+legal', g.committees.first.full_name, 'committee name update when group name changed.'
  end
  
  def test_create
    g = Committee.create
    assert !g.valid?, 'committee with no name should not be valid'
  end
  
  def test_assignment
    # we should be able to assign a parent even when the committee
    # has no name    
    parent = Group.create :name => 'parent'
    c = Committee.new
    c.parent = parent
    ## TODO: add a assert_raises nothing here
  end
  
  def test_associations
    assert check_associations(Committee)
  end
  
end

