require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase

  fixtures :users, :groups, :memberships

  def setup
    Time.zone = TimeZone["Pacific Time (US & Canada)"]
  end

  ## ensure that a user and a group cannot have the same handle
  def test_namespace
    assert_no_difference 'User.count' do
      u = create_user(:login => 'groups')
      assert u.errors.on(:login)
    end

    g = Group.create :name => 'robot-overlord'
    assert_no_difference 'User.count' do
      u = create_user(:login => 'robot-overlord')
      assert u.errors.on(:login)
    end
  end

  def test_associations
    assert check_associations(User)
  end

  def test_alphabetized
    assert_equal User.all.size, User.alphabetized('').size

    # find numeric group names
    assert_equal 0, User.alphabetized('#').size
    User.create! :login => '2unlimited', :password => '3qasdb43!sdaAS...', :password_confirmation => '3qasdb43!sdaAS...'
    assert_equal 1, User.alphabetized('#').size

    # case insensitive
    assert_equal User.alphabetized('G').size, User.alphabetized('g').size

    # nothing matches
    assert User.alphabetized('z').empty?
  end

  def test_peers_of
    u = users(:blue)
    assert_equal u.peers, User.peers_of(u)
  end

  protected

  def create_user(options = {})
    User.create({ :login => 'mrtester', :email => 'mrtester@riseup.net', :password => 'test', :password_confirmation => 'test' }.merge(options))
  end

end
