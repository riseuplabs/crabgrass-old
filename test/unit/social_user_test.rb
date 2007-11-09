require File.dirname(__FILE__) + '/../test_helper'

class SocialUserTest < Test::Unit::TestCase

  fixtures :users, :groups, :memberships, :pages

  def setup
    TzTime.zone = TimeZone["Pacific Time (US & Canada)"]
  end

  def test_memberships
    u = create_user :login => 'membershiptester'
    g = Group.find 1
    oldcount = g.users.count

    g.memberships.create :user => u
    # u.memberships.create :group => g (another valid way to do the same thing)
    assert oldcount < g.users.count, "group should have more users after add user"   
    assert_nothing_raised("group.users.find should return user") do
      g.users.find(u.id)
    end
    assert_nothing_raised("user.group.find should return group") do
      u.groups.find(g.id)
    end
    assert u.member_of?(g), 'user must be a member_of? group'

    u.groups.delete g
    assert !u.member_of?(g), 'user must NOT be a member_of? group'
  end

  def test_contacts
    a = users(:red)
    b = users(:green)
    
    assert !a.contacts.include?(b), 'no contact yet'
    a.contacts << b
    assert a.contacts.include?(b), 'should be contact'
    a.reload
    assert a.friend_id_cache.include?(b.id), 'friend id cache should be updated'
    a.contacts.delete(b)
    assert !a.contacts.include?(b), 'no contact now'
  end

  def test_duplicate_contacts
    a = users(:red)
    b = users(:green)
    
    a.contacts << b
    assert_raises(AssociationError) do
      a.contacts << b
    end
    assert_equal 1, Contact.count(:conditions => ['user_id = ? and contact_id = ?', a.id, b.id]), 'should be only be one contact, but there are really two'
  end

  def test_duplicate_memberships
    u = create_user :login => 'harry-potter'
    g = Group.create :name => 'hogwarts-academy'
    
    u.memberships.create :group => g
    assert_raises(AssociationError) do
      u.memberships.create :group => g
    end
  end
  
  def test_associations
    assert check_associations(SocialUser)
    assert check_associations(Contact)
  end  

  def test_group_membership_caching
    u = create_user :login => 'hermione'
    assert_equal [], u.group_ids, 'should be no group (id)'
    assert_equal [], u.all_group_ids, 'should be no group (all id)'
    assert_equal [], u.groups, 'should be no groups'
    assert_equal [], u.all_groups, 'should no all_groups'

    g = Group.create :name => 'hogwarts-academy'
    g.memberships.create :user => u

    assert_equal [g.id], u.group_ids, 'should be one group (id)'
    assert_equal [g.id], u.all_group_ids, 'should be one group (all id)'

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
    g.memberships.create :user => u

    assert_equal [g.id], u.all_group_ids, 'should be one group (all id)'

    # u.all_groups has not been cached, so doesn't need manually refreshed
    # u.all_groups.reload
    assert_equal [g], u.all_groups, 'should be one group (all)'

    c = Committee.create :name => 'dumbledores-army', :parent => g
    
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
    g1.memberships.create :user => u
    g2.memberships.create :user => u

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
        g[i].memberships.create :user => u
      end
    end
    
    assert_equal to_join.collect { |i| g[i].id}, u.group_ids.sort,
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

    g = []
    c = []
    
    committee_cnt = [15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,1,1,1,1,1]
    groups_to_join = [0,2,4,6,8,10,12,14,16,17,18]
    committees_to_join = [8,0,7,0,6,0,5,0,4,0,3,0,2,0,1,0,0,0,0,0]
    for i in 0..19
      g[i] = Group.create :name => 'group-%d' % i
    end
    
    for i in 0..19
      c[i] = []
      for j in 0..committee_cnt[i]
        c[i][j] = Committee.create :name => 'subgroup-%d-%d' % [i, j], :parent => g[i]
      end
    end
    
    for i in 0..19
      if groups_to_join.include? i
        u.memberships.create :group => g[i]
        for j in 0..committees_to_join[i]
          u.memberships.create :group => c[i][j]
        end
      end
    end

    correct_group_ids = []
    correct_all_group_ids = []
    for i in groups_to_join
      correct_group_ids += [g[i].id]
      correct_all_group_ids += [g[i].id]
      
      for j in 0..committee_cnt[i]
        if j <= committees_to_join[i]
          correct_group_ids += [c[i][j].id]
        end
        correct_all_group_ids += [c[i][j].id]
      end
    end

#    u.clear_cache
#    u.reload

    assert_equal correct_group_ids.sort, u.group_ids.sort,
                 'wrong groups (ids)'
    assert_equal correct_all_group_ids.sort, u.all_group_ids.sort,
                 'wrong groups (all ids)'
    assert_equal correct_group_ids.sort.collect { |i| Group.find(i)}, u.groups.sort_by {|x| x.id},
                 'wrong groups'
    assert_equal correct_all_group_ids.sort.collect { |i| Group.find(i)}, u.all_groups.sort_by {|x| x.id},
                 'wrong groups (all)'    
   end

  protected
    def create_user(options = {})
      User.create({ :login => 'mrtester', :email => 'mrtester@riseup.net', :password => 'test', :password_confirmation => 'test' }.merge(options))
    end
end
