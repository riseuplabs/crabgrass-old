class PageHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :page
  belongs_to :object, :polymorphic => true

  validates_presence_of :user, :page

  serialize :details, Hash

  def self.send_single_pending_notifications 
    pending_notifications.each do |page_history|
      recipients_for_single_notification(page_history).each do |user|
        if Conf.paranoid_emails?
          Mailer.deliver_page_history_single_notification_paranoid(user, page_history)
        else
          Mailer.deliver_page_history_single_notification(user, page_history)
        end
      end
      page_history.update_attribute :notification_sent_at, Time.now
    end
  end

  def self.send_digest_pending_notifications
    pending_digest_notifications_by_page.each do |page_id, page_histories|
      page = Page.find(page_id)
      recipients_for_digest_notifications(page).each do |user|
        if Conf.paranoid_emails?
          Mailer.deliver_page_history_digest_notification_paranoid(user, page, page_histories)
        else
          Mailer.deliver_page_history_digest_notification(user, page, page_histories)
        end
      end
      PageHistory.update_all("notification_digest_sent_at = '#{Time.now}'", ["notification_digest_sent_at IS NULL and page_id = (?)", page_id])
    end
  end

  def self.pending_digest_notifications_by_page
    histories = {}
    PageHistory.find(:all, :order => "created_at desc", :conditions => {:notification_digest_sent_at => nil}).each do |page_history|
      histories[page_history.page.id] = [] if histories[page_history.page_id].nil?
      histories[page_history.page.id] << page_history
    end
    histories
  end

  def self.pending_notifications
    PageHistory.find :all, :conditions => {:notification_sent_at => nil}
  end

  def self.recipients_for_page(page)
    UserParticipation.find(:all, :conditions => {:page_id => page.id, :watch => true}).map(&:user_id)
  end
  
  def self.recipients_for_digest_notifications(page)
    User.find :all, :conditions => ["receive_notifications = 'Digest' and id in (?)", recipients_for_page(page)]
  end

  def self.recipients_for_single_notification(page_history)
    users_watching_ids = recipients_for_page(page_history.page) 
    users_watching_ids.delete(page_history.user.id) 
    User.find :all, :conditions => ["receive_notifications = 'Single' and id in (?)", users_watching_ids]
  end

  protected

  def page_updated_at
    Page.update_all(["updated_at = ?", created_at], ["id = ?", page.id])
  end
end

class PageHistory::AddStar        < PageHistory; end
class PageHistory::RemoveStar     < PageHistory; end
class PageHistory::MakePublic     < PageHistory; end
class PageHistory::MakePrivate    < PageHistory; end
class PageHistory::StartWatching  < PageHistory; end
class PageHistory::StopWatching   < PageHistory; end

class PageHistory::PageCreated < PageHistory
  after_save :page_updated_at
end

class PageHistory::ChangeTitle < PageHistory
  before_save :add_details
  after_save :page_updated_at  

  def add_details
    self.details = {
      :from => self.page.title_was,
      :to   => self.page.title
    }
  end  
end

class PageHistory::Deleted < PageHistory
  after_save :page_updated_at  
end

class PageHistory::UpdatedContent < PageHistory
  after_save :page_updated_at  
end

class PageHistory::GrantGroupFullAccess < PageHistory
  after_save :page_updated_at  

  validates_format_of :object_type, :with => /Group/
  validates_presence_of :object_id
end

class PageHistory::GrantGroupWriteAccess < PageHistory
  after_save :page_updated_at  

  validates_format_of :object_type, :with => /Group/
  validates_presence_of :object_id
end

class PageHistory::GrantGroupReadAccess < PageHistory
  after_save :page_updated_at  

  validates_format_of :object_type, :with => /Group/
  validates_presence_of :object_id
end

class PageHistory::RevokedGroupAccess < PageHistory
  after_save :page_updated_at  

  validates_format_of :object_type, :with => /Group/
  validates_presence_of :object_id
end

class PageHistory::GrantUserFullAccess < PageHistory
  after_save :page_updated_at  
  
  validates_format_of :object_type, :with => /User/
  validates_presence_of :object_id
end

class PageHistory::GrantUserWriteAccess < PageHistory
  after_save :page_updated_at  
  
  validates_format_of :object_type, :with => /User/
  validates_presence_of :object_id
end

class PageHistory::GrantUserReadAccess < PageHistory
  after_save :page_updated_at  
  
  validates_format_of :object_type, :with => /User/
  validates_presence_of :object_id
end

class PageHistory::RevokedUserAccess < PageHistory
  after_save :page_updated_at  
  
  validates_format_of :object_type, :with => /User/
  validates_presence_of :object_id
end

class PageHistory::AddComment < PageHistory
  after_save :page_updated_at  
  
  validates_format_of :object_type, :with => /Post/
  validates_presence_of :object_id
end

class PageHistory::UpdateComment < PageHistory
  after_save :page_updated_at  
  
  validates_format_of :object_type, :with => /Post/
  validates_presence_of :object_id
end

class PageHistory::DestroyComment < PageHistory
  after_save :page_updated_at  
  
  validates_format_of :object_type, :with => /Post/
  validates_presence_of :object_id
end
