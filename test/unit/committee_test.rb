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

    assert_difference 'Group.find(%d).version'%g.id do
      g.add_committee!(c1)
    end
    assert_difference 'Group.find(%d).version'%g.id do
      g.add_committee!(c2)
    end
    g.reload
    assert_equal g, c1.parent, "committee's parent should match group"

    assert_difference 'Group.find(%d).version'%g.id, -1 do
      assert_difference 'Group.find(%d).committees.count'%g.id, -1 do
        c1.destroy_by(users(:red))
      end
    end
    g.destroy_by(users(:red))
    assert_nil Committee.find_by_name('food'), 'committee should die with group'
  end

  def test_destroy_group
    assert_nothing_raised do
      Group.find(groups(:warm).id)
    end
    groups(:rainbow).destroy_by(users(:red))
    assert_raises ActiveRecord::RecordNotFound, 'committee should be destroyed' do
      Group.find(groups(:warm).id)
    end
  end

  def test_membership
    g = Group.create :name => 'riseup'
    c1 = Committee.create :name => 'finance'
    c2 = Committee.create :name => 'food'
    g.add_committee!(c1)
    g.add_committee!(c2)
    user = users(:kangaroo)

    assert(!user.member_of?(g), 'user should not be member yet')

    g.add_user!(user)

    assert user.member_of?(g), 'user should be member of group'
    assert user.member_of?(c1), 'user should also be a member of committee'
    assert(user.direct_member_of?(g), 'user should be a direct member of the group')
    assert(!user.direct_member_of?(c1), 'user should not be a direct member of the committee')
    g.remove_user!(user)

    assert(!user.member_of?(g), 'user should not be member of group after being removed')
    assert(!user.member_of?(c1), 'user should not be a member of committee')
  end

  def test_naming
    g = Group.create :name => 'riseup'
    c = Committee.new :name => 'outreach'
    g.add_committee!(c)
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

  def test_associations
    assert check_associations(Committee)
  end

  def test_member_of_committee_but_not_of_group_cannot_access_group_pages
    g = Group.create :name => 'riseup'
    c = Committee.create :name => 'outreach'
    g.add_committee!(c)
    user = users(:gerrard)
    other_user = users(:blue)
    c.add_user!(user)
    c.add_user!(other_user)
    c.save
    g.add_user!(other_user)
    g.save

    assert user.may?(:admin, c)

    group_page = Page.create! :title => 'a group page',
      :public => false,
      :user => other_user,
      :share_with => g, :access => :admin
    group_page.save
    committee_page = Page.create! :title => 'a committee page',
      :public => false,
      :user => other_user,
      :share_with => c, :access => :admin
    committee_page.save

    assert user.may?(:view, committee_page), "should be able to view committee page"
    assert !user.may?(:view, group_page), "should not be able to view group page"
  end

  def test_cant_pester_private_committee
    g = Group.create :name => 'riseup'
    c = Committee.create :name => 'outreach'
    g.add_committee!(c)

    u = User.create :login => 'user'

    assert c.may_be_pestered_by?(u) == false, 'should not be able to be pestered by user'
    assert u.may_pester?(c) == false, 'should not be able to pester committee of group with private committees'
  end

  def test_can_pester_public_committee
    g = Group.create :name => 'riseup'
    g.profiles.public.update_attribute(:may_see, true)
    g.profiles.public.update_attribute(:may_see_committees, true)
    c = Committee.create :name => 'outreach'
    g.add_committee!(c)

    u = User.create :login => 'user'

    assert c.may_be_pestered_by?(u), 'should be able to be pestered by user'
    assert u.may_pester?(c), 'should be able to pester committee of group with public committees'
  end

  def test_add_council
    network = groups(:cnt)
    council = Council.create!(:name => 'council')
    network.add_committee!(council)
    network.reload
    council.reload
    assert_equal 'Network', network.type
    assert_equal 'Council', council.type
    assert_equal council.id, network.council_id
    assert_equal council, network.council
    assert_equal network.id, council.parent_id
  end

end

