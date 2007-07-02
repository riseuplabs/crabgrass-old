require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < Test::Unit::TestCase
  fixtures :groups, :users

  def test_memberships
    g = Group.create :name => 'fruits'
    u = users(:blue)
    assert_equal 0, g.users.size, 'there should be no users'
    g.users << u
    assert_equal 1, g.users.size, 'there should be one user'

    g.memberships.create :user_id => users(:red).id, :page_id => 1
    g.reload
    assert_equal 2, g.users.size, 'there should be two users'
    
    g.memberships.each do |m|
      m.destroy
    end
    g.reload
    assert_equal 0, g.users.size, 'there should be no users'
  end

  def test_associations
    assert check_associations(Group)
  end

end
