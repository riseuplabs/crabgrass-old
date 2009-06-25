require File.dirname(__FILE__) + '/../test_helper'

class RelationshipsTest < Test::Unit::TestCase
  fixtures :users

  def test_add_contact
    a = users(:red)
    b = users(:green)
    
    assert !a.contacts.include?(b), 'no contact yet'
    assert_difference 'Relationship.count', 2 do
      a.add_contact!(b)
    end
    assert a.contacts.include?(b), 'should be contact'
    assert b.contacts.include?(a), 'should be contact'
  end

  def test_friends
    a = users(:red)
    b = users(:green)

    assert_difference 'Friendship.count', 2 do
      a.add_contact!(b, :friend)
    end

    assert a.friends.include?(b)
    assert a.friend_id_cache.include?(b.id), 'friend id cache should be updated'
    assert a.friend_of?(b), 'should be friends'
    assert b.friend_of?(a), 'should be friends both ways'

    a.remove_contact!(b)

    assert !a.friend_of?(b), 'no contact now'
  end

  def test_destroy
    a = users(:red)
    b = users(:green)
    
    a.add_contact!(b)
    a.reload; b.reload
    assert_difference 'Relationship.count', -2 do
      a.remove_contact!(b)
    end
    assert !a.contacts.include?(b), 'no contact now'
  end

  def test_remove_in_memory
    a = users(:red)
    b = users(:green)
    
    a.add_contact!(b)
    a.remove_contact!(b)
    assert !a.contacts.include?(b), 'no contact now'
  end

  def test_duplicate_contacts
    a = users(:red)
    b = users(:green)

    assert_difference 'Relationship.count', 2 do
      a.add_contact!(b)
      a.add_contact!(b)
    end

    assert_equal 1, Relationship.count(:conditions => ['user_id = ? and contact_id = ?', a.id, b.id]), 'should be only be one contact, but there are really two'
  end

  def test_different_types
    a = users(:red)
    b = users(:green)
    c = users(:blue)
 
    a.add_contact!(b)
    a.add_contact!(c, :friend)
    
    assert !a.friends.include?(b)
    assert a.friends.include?(c)
    assert a.contacts.include?(b)
    assert a.contacts.include?(c)
  end

  def test_relationship_discussion
    a = users(:red)
    b = users(:green)
    a.add_contact!(b)
    
    assert_no_difference 'Discussion.count' do
      a.relationships.with(b)
    end

    discussion = nil    
    assert_difference 'Discussion.count' do 
      discussion = a.relationships.with(b).discussion
    end

    assert discussion
    assert_equal discussion, b.relationships.with(a).discussion

  end

  def test_associations
    assert check_associations(Relationship)
  end  

end

