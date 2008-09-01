require File.dirname(__FILE__) + '/../test_helper'

class SocialUserTest < Test::Unit::TestCase

  fixtures :users, :groups, :pages

  def setup
    Time.zone = TimeZone["Pacific Time (US & Canada)"]
  end

  def test_peers
    group = groups(:animals)
    u1 = users(:red)
    u2 = users(:kangaroo)

    assert !u1.peer_of?(u2), 'red and kangaroo should not be peers'
    assert !u2.peer_of?(u1), 'red and kangaroo should not be peers'

    m = group.memberships.create :user => u1
    u1.reload; u2.reload

    assert u1.peer_of?(u2), 'user with membership change (red) should have other user (kangaroo) as a peer'
    assert u2.peer_of?(u1), 'other user (kangaroo) should have user with membership change (red) as a peer.'

    u1.groups.delete group
    u1.reload; u2.reload

    assert !u1.peer_of?(u2), 'red and kangaroo should not be peers'
    assert !u2.peer_of?(u1), 'red and kangaroo should not be peers'

    u1.memberships.create :group => group
    u1.reload; u2.reload

    assert u1.peer_of?(u2), 'user with membership change (red) should have other user (kangaroo) as a peer'
    assert u2.peer_of?(u1), 'other user (kangaroo) should have user with membership change (red) as a peer.'

    group.users.delete u1
    u1.reload; u2.reload

    assert !u1.peer_of?(u2), 'red and kangaroo should not be peers'
    assert !u2.peer_of?(u1), 'red and kangaroo should not be peers'
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

  def test_associations
    assert check_associations(User)
    assert check_associations(Contact)
  end  

  def test_pestering
    assert users(:kangaroo).stranger_to?(users(:green)), 'must be strangers'
    assert !users(:kangaroo).may_pester?(users(:green)), 'strangers should not be able to pester'

    assert users(:red).peer_of?(users(:green)), 'must be peers'
    assert !users(:red).may_pester?(users(:green)), 'peers should be able to pester'

    users(:green).profiles.public.may_pester = true
    users(:green).profiles.public.save
    assert users(:kangaroo).may_pester?(users(:green)), 'should be able to pester if set in profile'
  end
  
  protected
    def create_user(options = {})
      user = User.new({ :login => 'mrtester', :email => 'mrtester@riseup.net', :password => 'test', :password_confirmation => 'test' }.merge(options))
      user.profiles.build :first_name => "Test", :last_name => "Test", :friend => true
      user.save!
      user
    end
end
