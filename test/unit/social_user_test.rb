require File.dirname(__FILE__) + '/../test_helper'

class SocialUserTest < Test::Unit::TestCase

  fixtures :users, :groups, :pages, :relationships

  def setup
    Time.zone = TimeZone["Pacific Time (US & Canada)"]
  end

  def test_peers
    group = groups(:animals)
    u1 = users(:red)
    u2 = users(:kangaroo)

    assert !u1.peer_of?(u2), 'red and kangaroo should not be peers'
    assert !u2.peer_of?(u1), 'red and kangaroo should not be peers'

    group.add_user! u1
    group.add_user!(u2) unless u2.direct_member_of?(group)
    u1.reload; u2.reload

    assert u1.peer_of?(u2), 'user with membership change (red) should have other user (kangaroo) as a peer'
    assert u2.peer_of?(u1), 'other user (kangaroo) should have user with membership change (red) as a peer.'

    group.remove_user! u1
    u1.reload; u2.reload

    assert !u1.peer_of?(u2), 'red and kangaroo should not be peers'
    assert !u2.peer_of?(u1), 'red and kangaroo should not be peers'

    group.add_user!(u1) unless u1.direct_member_of?(group)
    u1.reload; u2.reload

    assert u1.peer_of?(u2), 'user with membership change (red) should have other user (kangaroo) as a peer'
    assert u2.peer_of?(u1), 'other user (kangaroo) should have user with membership change (red) as a peer.'

    group.remove_user! u1
    u1.reload; u2.reload

    assert !u1.peer_of?(u2), 'red and kangaroo should not be peers'
    assert !u2.peer_of?(u1), 'red and kangaroo should not be peers'
  end

  def test_associations
    assert check_associations(User)
  end

  def test_pestering
    group = groups(:rainbow)
    green = users(:green)
    green.profiles.public.may_pester = false
    green.profiles.public.save
    assert users(:kangaroo).stranger_to?(green), 'must be strangers'
    assert !users(:kangaroo).may_pester?(green), 'strangers should be not be able to pester'

    red = users(:red)
    group.add_user!(red) unless red.direct_member_of?(group)
    group.add_user!(green) unless green.direct_member_of?(group)
    red.reload; green.reload;
    assert red.peer_of?(green), 'must be peers'
    assert !red.may_pester?(green), 'peers should not be able to pester'

    green.profiles.public.may_pester = true
    green.profiles.public.save
    assert users(:kangaroo).may_pester?(green), 'should be able to pester if set in profile'

    blue = users(:blue)
    blue.profiles.public.may_pester = false
    blue.profiles.public.save
    blue.profiles.private.may_see = true
    blue.profiles.private.save
    assert blue.profiles.visible_by(users(:orange)) == blue.profiles.private, 'friends should see private profiles if may_see is true'
    assert users(:orange).friend_of?(blue), 'must be friends'
    assert users(:orange).may_pester?(blue), 'friends can always pester'
    blue.profiles.private.may_pester = false
    blue.profiles.private.save
    assert !users(:orange).may_pester?(blue), 'friends should not be able to pester if may_pester_by_friends is false'
  end

  protected
    def create_user(options = {})
      user = User.new({ :login => 'mrtester', :email => 'mrtester@riseup.net', :password => 'test', :password_confirmation => 'test' }.merge(options))
      user.profiles.build :first_name => "Test", :last_name => "Test", :friend => true
      user.save!
      user
    end
end
