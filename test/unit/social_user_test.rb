require File.dirname(__FILE__) + '/../test_helper'

class SocialUserTest < ActiveSupport::TestCase

  fixtures :users, :groups, :pages

  def setup
    Time.zone = ActiveSupport::TimeZone["Pacific Time (US & Canada)"]
  end

  def test_peers
    group = groups(:animals)
    u1 = users(:red)
    u2 = users(:kangaroo)

    assert !u1.peer_of?(u2), 'red and kangaroo should not be peers'
    assert !u2.peer_of?(u1), 'red and kangaroo should not be peers'

    group.add_user! u1
    u1.reload; u2.reload

    assert u1.peer_of?(u2), 'user with membership change (red) should have other user (kangaroo) as a peer'
    assert u2.peer_of?(u1), 'other user (kangaroo) should have user with membership change (red) as a peer.'

    group.remove_user! u1
    u1.reload; u2.reload

    assert !u1.peer_of?(u2), 'red and kangaroo should not be peers'
    assert !u2.peer_of?(u1), 'red and kangaroo should not be peers'

    group.add_user! u1
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
    users(:green).profiles.public.may_pester = false
    assert users(:kangaroo).stranger_to?(users(:green)), 'must be strangers'
    assert users(:kangaroo).may_pester?(users(:green)), 'strangers should be not be able to pester'

    assert users(:red).peer_of?(users(:green)), 'must be peers'
    assert users(:red).may_pester?(users(:green)), 'peers should always be able to pester'

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
