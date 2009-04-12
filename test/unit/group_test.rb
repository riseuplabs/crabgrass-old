require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < Test::Unit::TestCase
  fixtures :groups, :users, :profiles, :memberships

  def test_memberships
    g = Group.create :name => 'fruits'
    u = users(:blue)
    assert_equal 0, g.users.size, 'there should be no users'
    assert_raises(Exception, '<< should raise exception not allowed') do
      g.users << u
    end
    g.add_user! u
    g.add_user! users(:red)

    assert u.member_of?(g), 'user should be member of group'
    
    g.memberships.each do |m|
      m.destroy
    end
    g.reload
    assert_equal 0, g.users.size, 'there should be no users'
  end

  def test_missing_name
    g = Group.create
    assert !g.valid?, 'group with no name should not be valid'
  end

  def test_duplicate_name
    g1 = Group.create :name => 'fruits'
    assert g1.valid?, 'group should be valid'

    g2 = Group.create :name => 'fruits'
    assert g2.valid? == false, 'group should not be valid'
  end

  def test_try_to_create_group_with_same_name_as_user
    u = User.find(1)
    assert u.login, 'user should be valid'

    g = Group.create :name => u.login
    assert g.valid? == false, 'group should not be valid'
    assert g.save == false, 'group should fail to save'
  end

  def test_cant_pester_private_group
    g = Group.create :name => 'riseup'
    g.publicly_visible_group = false
    u = User.create :login => 'user'
    
    assert g.may_be_pestered_by?(u) == false, 'should not be able to be pestered by user'
    assert u.may_pester?(g) == false, 'should not be able to pester private group'
  end

  def test_can_pester_public_group
    g = Group.create :name => 'riseup'
    g.publicly_visible_group = true
    u = User.create :login => 'user'
    
    assert g.may_be_pestered_by?(u) == true, 'should be able to be pestered by user'
    assert u.may_pester?(g) == true, 'should be able to pester private group'
  end

  def test_association_callbacks
    g = Group.create :name => 'callbacks'
    g.expects(:check_duplicate_memberships)
    u = users(:blue)
    g.add_user!(u)
  end
  
  def test_committee_access
    g = groups(:public_group)
    assert_equal [groups(:public_committee)],
                 g.committees_for(:public).sort_by{|c| c.id},
                 "should find 1 public committee"
    assert_equal [groups(:public_committee), groups(:private_committee)].sort_by{|c| c.id},
                 g.committees_for(:private).sort_by{|c| c.id},
                 "should find 2 committee with private access"
  end

  def test_councils
    group = groups(:rainbow)
    committee = groups(:cold)
    blue = users(:blue)
    red  = users(:red)

    assert_equal committee.parent, group
    assert blue.direct_member_of?(committee)
    assert !red.direct_member_of?(committee)
    
    assert red.may?(:admin, group)
    assert blue.may?(:admin, group)

    assert_nothing_raised do
      group.add_committee!(committee, true)
    end
 
    red.reload
    blue.reload

    assert !red.may_admin?(group)
    assert !red.may?(:admin, group)
    assert blue.may?(:admin, group)   
  end

  def test_name_change
    group = groups(:true_levellers)
    user = users(:gerrard)

    version = user.version

    group.name = 'diggers'
    group.save!

    # note: if the group has a committee, and the user is a member of that
    # committee, then the user's version will increment by more than one, 
    # since the committees also experience a name change.
    assert_equal version+1, user.reload.version, 'user version should increment on group name change'
  end
  
  def test_associations
    assert check_associations(Group)
  end

  def test_alphabetized
    assert_equal Group.all.size, Group.alphabetized('').size

    # find numeric group names
    assert_equal 0, Group.alphabetized('#').size
    Group.create :name => '1more'
    assert_equal 1, Group.alphabetized('#').size

    # case insensitive
    assert_equal Group.alphabetized('r').size, Group.alphabetized('R').size

    # nothing matches
    assert Group.alphabetized('z').empty?
  end

end
