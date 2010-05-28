require File.dirname(__FILE__) + '/../test_helper'
class SubscriptionTest < ActiveSupport::TestCase
  fixtures :users, :groups, :profiles

  def setup
  end

  def test_if_a_new_user_participation_has_a_subscription

  end

  def test_if_the_subscription_is_properly_deleted_when_the_user_participation_is_deleted

  end

  def test_if_the_inbox_notification_is_only_sent_when_required
  end

  def test_if_the_mail_notification_is_only_sent_when_required
    # ensure, a mail cannot be sent insecure if secure delivery required
  end

  def test_that_changes_on_the_page_dont_show_up_if_it_was_only_a_notification
  end

  def test_that_there_is_no_change_to_the_access_level_unless_selected
  end
end
