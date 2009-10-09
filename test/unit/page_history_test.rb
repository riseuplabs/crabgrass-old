require File.dirname(__FILE__) + '/../test_helper'

class PageHistoryTest < Test::Unit::TestCase

  def setup
    Page.delete_all
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    
    @user = User.make :login => "pepe"
    User.current = @user
    @site = Site.make(:domain => "crabgrass.org", :title => "Crabgrass Social Network", :email_sender => "robot@$current_host")
    @page = Page.make_owned_by(:site => @site, :user => @user, :owner => @user, :access => 1)
  end

  def teardown
    Page.delete_all
    User.delete_all
    User.current = nil
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
  end

  def test_recipients_for_single_notifications
    user   = User.make :login => "user", :receive_notifications => nil
    user_a = User.make :login => "user_a", :receive_notifications => "Digest"
    user_b = User.make :login => "user_b", :receive_notifications => "Single"
    user_c = User.make :login => "user_c", :receive_notifications => "Single"
    User.current = user_a
    UserParticipation.make_unsaved(:page => @page, :user => user_a, :watch => true).save!
    User.current = user_b
    UserParticipation.make_unsaved(:page => @page, :user => user_b, :watch => true).save!
    User.current = user_c
    UserParticipation.make_unsaved(:page => @page, :user => user_c, :watch => true).save!

    assert_equal 1, PageHistory::StartWatching.recipients(PageHistory::StartWatching.last, "Single").count

    # this should not receive notifications because he has it disabled 
    assert !PageHistory::StartWatching.recipients(PageHistory::StartWatching.last, "Single").include?(user)

    # this should not receive notifications because he has Digest enabled 
    assert !PageHistory::StartWatching.recipients(PageHistory::StartWatching.last, "Single").include?(user_a)

    # this should receibe notifications because he has it enabled
    assert PageHistory::StartWatching.recipients(PageHistory::StartWatching.last, "Single").include?(user_b)

    # this should not receive_notifications because he was the performer
    assert !PageHistory::StartWatching.recipients(PageHistory::StartWatching.last, "Single").include?(user_c)
  end  

  def test_pending_notifications
    assert_equal 1, PageHistory.pending_notifications.size
  end

  def test_send_pending_notifications
    user_a = User.make :receive_notifications => "Single" 
    User.current = user_a
    UserParticipation.make_unsaved(:page => @page, :user => user_a, :watch => true).save!
    PageHistory.send_pending_notifications
    assert_equal 1, ActionMailer::Base.deliveries.count
    assert_equal 0, PageHistory.pending_notifications.size
  end
end
