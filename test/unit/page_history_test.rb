require File.dirname(__FILE__) + '/../test_helper'

class PageHistoryTest < Test::Unit::TestCase

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    
    @user = User.make :login => "pepe"
    User.current = @user
    @site = Site.make(:domain => "crabgrass.org", :title => "Crabgrass Social Network", :email_sender => "robot@$current_host")
    @page = Page.make_owned_by(:site => @site, :user => @user, :owner => @user, :access => 1)
  end

  def test_validations
    assert_raise ActiveRecord::RecordInvalid do PageHistory.create!(:user => nil, :page => nil) end
    assert_raise ActiveRecord::RecordInvalid do PageHistory.create!(:user => @user, :page => nil) end
    assert_raise ActiveRecord::RecordInvalid do PageHistory.create!(:user => nil, :page => @page) end
  end

  def test_associations
    page_history = PageHistory.create!(:user => @user, :page => @page)
    assert_equal @user, page_history.user
    assert_kind_of Page, page_history.page
    assert_equal @page.page_history.last, PageHistory.last
  end

  def test_recipients
    user_a = User.make :login => "user_a"; user_b = User.make :login => "user_b"
    User.current = user_a
    UserParticipation.make_unsaved(:page => @page, :user => user_a, :watch => true).save!
    User.current = user_b
    UserParticipation.make_unsaved(:page => @page, :user => user_b, :watch => true).save!
    assert PageHistory::StartWatching.recipients(PageHistory::StartWatching.last).include?(user_a)
    assert !PageHistory::StartWatching.recipients(PageHistory::StartWatching.last).include?(user_b)
  end  

  def test_pending_notifications
    assert_equal 1, PageHistory.pending_notifications.size
  end

  def test_send_pending_notifications
    user_a = User.make 
    User.current = user_a
    UserParticipation.make_unsaved(:page => @page, :user => user_a, :watch => true).save!
    PageHistory.send_pending_notifications
    assert_equal 1, ActionMailer::Base.deliveries.count
    assert_equal 0, PageHistory.pending_notifications.size
  end
end
