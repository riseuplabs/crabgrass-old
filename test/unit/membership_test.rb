require File.dirname(__FILE__) + '/../test_helper'

class MembershipTest < ActiveSupport::TestCase

  fixtures :users, :groups, :memberships

  def setup
    Time.zone = ActiveSupport::TimeZone["Pacific Time (US & Canada)"]
  end

  def test_memberships
    u = create_user :login => 'membershiptester'
    g = Group.find 1
    oldcount = g.users.count
    oldversion = g.version

    g.add_user! u
    assert oldcount < g.users.count, "group should have more users after add user"
    assert_nothing_raised("group.users.find should return user") do
      g.users.find(u.id)
    end
    assert_nothing_raised("user.group.find should return group") do
      u.groups.find(g.id)
    end
    assert u.member_of?(g), 'user must be a member_of? group'

    assert_equal oldversion+1, g.version, 'group version should increment'

    u.groups.delete g
    assert !u.member_of?(g), 'user must NOT be a member_of? group'
    assert_equal oldversion+2, g.version, 'group version should increment'
  end

  def test_deleting_memberships
    u1 = create_user :login => 'testy_one'
    u2 = create_user :login => 'testy_two'
    g = groups(:animals)

    membership1 = g.add_user! u1
    membership2 = g.add_user! u2

    assert_difference 'groups(:animals).version' do
      g.remove_user! u1
      assert !u1.member_of?(g), 'user1 must NOT be a member_of? group'
    end
  end

  def test_duplicate_memberships
    u = create_user :login => 'harry-potter'
    g = Group.create :name => 'hogwarts-academy'

    g.add_user! u
    assert_raises(AssociationError) do
      g.add_user! u
    end
  end

  def test_group_membership_caching
    u = create_user :login => 'hermione'
    assert_equal [], u.group_ids, 'should be no group (id)'
    assert_equal [], u.all_group_ids, 'should be no group (all id)'
    assert_equal [], u.groups, 'should be no groups'
    assert_equal [], u.all_groups, 'should no all_groups'

    g = Group.create :name => 'hogwarts-academy'
    g.add_user! u

    assert_equal [g.id], u.all_group_ids, 'should be one group (all id)'
    assert_equal [g.id], u.group_ids, 'should be one group (id)'

    # u.groups is already cached, must be manually refreshed
    u.groups.reload
    assert_equal [g], u.groups, 'should be one group'

    # u.all_groups is already cached, and must be manually refreshed
    u.all_groups.reload
    assert_equal [g], u.all_groups, 'should be one group (all)'
  end

  def test_group_membership_caching_with_a_committee
    u = create_user :login => 'ron'

    g = Group.create :name => 'hogwarts-academy'
    g.add_user! u

    assert_equal [g.id], u.all_group_ids, 'should be one group (all id)'

    # u.all_groups has not been cached, so doesn't need manually refreshed
    # u.all_groups.reload
    assert_equal [g], u.all_groups, 'should be one group (all)'

    c = Committee.new :name => 'dumbledores-army'
    g.add_committee!(c)

    assert_equal [g.id], u.group_ids, 'should be one direct group (id)'

    # u.groups has not been cached, so doesn't need manually refreshed
    # u.groups.reload
    assert_equal [g], u.groups, 'should be one direct group'

    # for the indirect membership values to be correct,
    # we must clear the cache and reload the options.
    assert_equal [g.id], u.all_group_ids, 'should be one group before cache refresh (all id)'
    assert_equal [g], u.all_groups, 'should be one group before cache refresh (all)'

    u.clear_cache
    u.reload

    assert_equal [g.id, c.id].sort, u.all_group_ids.sort, 'should be two groups after cache refresh (all id)'
    assert_equal [g, c].sort_by {|g| g.id}, u.all_groups.sort_by {|g| g.id},
                 'should be two groups overall (all)'
  end

  def test_clear_id_cache
    u = create_user :login => 'peter'

    g1 = Group.create :name => 'pumpkin'
    g2 = Group.create :name => 'eaters'
    g1.add_user! u
    g2.add_user! u

    #u.clear_cache
    #u = User.find_by_login 'peter'
    #assert_equal [g1.id, g2.id], all_group_id_cache, 'the serialize as intarray is not working!'
    u = User.find_by_login 'peter'
    assert_equal [g1.id, g2.id], u.all_group_id_cache, 'the serialize as intarray is not working!!'
    #y u.all_group_id_cache
  end

  def test_create_many_groups_join_some
    u = create_user :login => 'pippi'

    g = []
    to_join = [2,3,5,7,11,13,17,19]
    for i in 0..19
      g[i] = Group.create :name => 'group-%d' % i
      if to_join.include? i
        g[i].add_user! u
      end
    end

    assert_equal to_join.collect{ |i| g[i].id}, u.group_ids.sort,
                 'wrong groups (id)'
    assert_equal to_join.collect { |i| g[i].id}, u.all_group_ids.sort,
                 'wrong groups (all id)'
    assert_equal to_join.collect { |i| g[i]}, u.groups.sort_by {|x| x.id},
                 'wrong groups'
    assert_equal to_join.collect { |i| g[i]}, u.all_groups.sort_by {|x| x.id},
                 'wrong groups (all)'
  end

  def test_create_many_groups_and_committees_join_some
    u = create_user
    max_committees_per_group = 3
    max_groups = 10
    correct_group_ids = []
    correct_all_group_ids = []
    groups = []

    ## create groups
    max_groups.times do |i|
      group = Group.create(:name => ('group-%d' % i))
      groups << group
      (rand(max_committees_per_group+1)).times do |j|
        group.add_committee! Committee.create( :name => ('subgroup-%d-%d' % [i, j]) )
      end
    end

    ## create memberships
    groups.each do |group|
      if rand(2)==0
        group.add_user! u
        correct_group_ids     << group.id
        correct_all_group_ids << group.id
        group.committees.each do |c|
          correct_all_group_ids << c.id
          if rand(2)==0
            correct_group_ids << c.id
            c.add_user! u
          end
        end
      end
    end

    assert_equal(
      correct_group_ids.sort,
      u.group_ids.sort,
      'wrong groups (ids)')

    assert_equal(
      correct_all_group_ids.sort,
      u.all_group_ids.sort,
      'wrong groups (all ids)')

    assert_equal(
      correct_group_ids.sort.collect { |i| Group.find(i)},
      u.groups.sort_by {|x| x.id},
      'wrong groups'
    )

    assert_equal(
      correct_all_group_ids.sort.collect { |i| Group.find(i)},
      u.all_groups.sort_by {|x| x.id},
      'wrong groups (all)'
    )

  end

  protected
    def create_user(options = {})
      user = User.new({ :login => 'mrtester', :email => 'mrtester@riseup.net', :password => 'test', :password_confirmation => 'test' }.merge(options))
      user.profiles.build :first_name => "Test", :last_name => "Test", :friend => true
      user.save!
      user
    end
end
