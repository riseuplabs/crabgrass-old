require File.dirname(__FILE__) + '/../test_helper'

class UserSettingTest < ActiveSupport::TestCase
  def test_ensure_values_in_receive_notifications 
    user = User.make

    user.receive_notifications = nil
    user.save!
    assert_equal nil, user.receive_notifications

    user.receive_notifications = true
    user.save!
    assert_equal nil, user.receive_notifications

    user.receive_notifications = false
    user.save!
    assert_equal nil, user.receive_notifications

    user.receive_notifications = "Any" 
    user.save!
    assert_equal nil, user.receive_notifications

    user.receive_notifications = "Digest" 
    user.save!
    assert_equal "Digest", user.receive_notifications

    user.receive_notifications = "Single" 
    user.save!
    assert_equal "Single", user.receive_notifications

    user.receive_notifications = "" 
    user.save!
    assert_equal nil, user.receive_notifications
  end
end
