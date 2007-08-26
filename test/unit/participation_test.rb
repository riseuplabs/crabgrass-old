require File.dirname(__FILE__) + '/../test_helper'

class ParticipationTest < Test::Unit::TestCase

  fixtures :users, :pages, :user_participations

  def setup
    TzTime.zone = TimeZone["Pacific Time (US & Canada)"]
  end

  def test_associations
    assert check_associations(UserParticipation)
  end

  def test_viewed
    p = pages(:page1)
    p.updated_at = Time.now
    p.save
    user = users(:orange)
    part = p.participation_for_user user
    assert !part.viewed_at
    user.viewed(p)
    part.reload
    assert part.viewed_at
  end

  def test_name_changed
    u = users(:orange)
    p = Page.create :title => 'hello'
    assert p.valid?, 'page should be valid'
    u.updated(p)
    assert_equal 'orange', p.updated_by_login, 'cached updated_by_login should be "orange"'
    u.login = 'banana'
    u.save
    p.reload
    assert_equal 'banana', p.updated_by_login, 'cached updated_by_login should be "banana"'
  end
    
  protected
    def create_user(options = {})
      User.create({ :login => 'mrtester', :email => 'mrtester@riseup.net', :password => 'test', :password_confirmation => 'test' }.merge(options))
    end
end

