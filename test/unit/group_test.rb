require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < Test::Unit::TestCase
  fixtures :groups, :users

  def test_memberships
    g = Group.create :name => 'fruits'
    u = users(:blue)
    assert_equal 0, g.users.size, 'there should be no users'
	assert_raises(Exception, '<< should raise exception not allowed') do
      g.users << u
	end
	g.memberships.create :user => u
    g.memberships.create :user_id => users(:red).id, :page_id => 1

    assert u.member_of?(g), 'user should be member of group'
    
    g.memberships.each do |m|
      m.destroy
    end
    g.reload
    assert_equal 0, g.users.size, 'there should be no users'
  end

  def test_name
    g = Group.create
    assert !g.valid?, 'group with no name should not be valid'
  end

  def test_associations
    assert check_associations(Group)
  end

end
