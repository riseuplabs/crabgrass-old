require File.dirname(__FILE__) + '/../test_helper'
require 'mailer'

class MailerPageHistoryTest < Test::Unit::TestCase
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @user_a = User.make :login => "miguel", :display_name => "Miguel Bakunin"
    @user_b = User.make :login => "anselme", :display_name => "Anselme Belgarin"
    User.current = @user
    @site = Site.make(:domain => "crabgrass.org", :title => "Crabgrass Social Network", :email_sender => "robot@$current_host")
    @page = Page.make_owned_by(:user => @user, :owner => @user, :access => 1, :site => @site)
  end

  def test_send_watched_notification
    page_history = PageHistory::AddStar.create!(:user => @user_a, :page => @page)
    message = Mailer.create_send_watched_notification(@user_b, page_history)
    assert_equal "Crabgrass Social Network : #{@page.title}", message.subject
    assert_equal [@user_b.email], message.to
    assert_equal ["robot@crabgrass.org"], message.from
    assert message.body.match(/Hello Anselme Belgarin/)
    assert message.body.match(/Miguel Bakunin/)
    assert message.body.match(/The page \"#{@page.title}/)
    assert message.body.match(/in network \"#{@site.title}/)
    assert message.body.match(/added a star/)
  end

  def test_send_digest_notification
    page_histories = []
    page_histories << PageHistory::AddStar.create!(:user => @user_a, :page => @page)
    page_histories << PageHistory::RemoveStar.create!(:user => @user_b, :page => @page)
    message = Mailer.create_send_digest_pending_notifications(@user_a, @page, page_histories)
    assert_equal "Crabgrass Social Network : #{@page.title}", message.subject
    assert_equal [@user_a.email], message.to
    assert message.body.match(/Hello Miguel Bakunin/)
    assert message.body.match(/Anselme Belgarin/)
    assert message.body.match(/has been modified,\nthis is a digest email resuming the last changes/)
    assert message.body.match(/The page \"#{@page.title}/)
    assert message.body.match(/in network \"#{@site.title}/)
    assert message.body.match(/added a star/)
    assert message.body.match(/removed a star/)
  end
end
