require File.dirname(__FILE__) + '/../test_helper'

class ContactsTest < Test::Unit::TestCase
  fixtures :users

  def test_contacts
    a = users(:red)
    b = users(:green)
    
    assert !a.contacts.include?(b), 'no contact yet'
    a.contacts << b
    assert a.contacts.include?(b), 'should be contact'
    a.reload
    assert a.friend_id_cache.include?(b.id), 'friend id cache should be updated'
    assert a.friend_of?(b), 'should be friends'
    assert b.friend_of?(a), 'should be friends both ways'
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

  def test_associations
    assert check_associations(Contact)
  end  

end
