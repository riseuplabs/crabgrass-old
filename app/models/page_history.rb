class PageHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :page
  belongs_to :object, :polymorphic => true

  validates_presence_of :user, :page

  def self.send_pending_notifications
    pending_notifications.each do |page_history|
      recipients(page_history, "Single").each do |user|
        Mailer.deliver_send_watched_notification(user, page_history)
      end
      page_history.update_attribute :notification_sent_at, Time.now
    end
  end

  def self.pending_notifications
    PageHistory.find :all, :conditions => {:notification_sent_at => nil}
  end

  def self.recipients(page_history, method)
    users_watching_ids = UserParticipation.find(:all, :conditions => {:page_id => page_history.page.id, :watch => true}).map(&:user_id)
    users_watching_ids.delete(page_history.user.id)
    User.find :all, :conditions => ["receive_notifications = (?) and id in (?)", method, users_watching_ids]
  end
end

class PageHistory::ChangeTitle    < PageHistory; end
class PageHistory::AddStar        < PageHistory; end
class PageHistory::RemoveStar     < PageHistory; end
class PageHistory::MakePublic     < PageHistory; end
class PageHistory::MakePrivate    < PageHistory; end
class PageHistory::Deleted        < PageHistory; end
class PageHistory::StartWatching  < PageHistory; end
class PageHistory::StopWatching   < PageHistory; end
class PageHistory::UpdatedContent < PageHistory; end

class PageHistory::GrantGroupFullAccess < PageHistory
  validates_format_of :object_type, :with => /Group/
  validates_presence_of :object_id
end

class PageHistory::GrantGroupWriteAccess < PageHistory
  validates_format_of :object_type, :with => /Group/
  validates_presence_of :object_id
end

class PageHistory::GrantGroupReadAccess < PageHistory
  validates_format_of :object_type, :with => /Group/
  validates_presence_of :object_id
end

class PageHistory::RevokedGroupAccess < PageHistory
  validates_format_of :object_type, :with => /Group/
  validates_presence_of :object_id
end

class PageHistory::GrantUserFullAccess < PageHistory
  validates_format_of :object_type, :with => /User/
  validates_presence_of :object_id
end

class PageHistory::GrantUserWriteAccess < PageHistory
  validates_format_of :object_type, :with => /User/
  validates_presence_of :object_id
end

class PageHistory::GrantUserReadAccess < PageHistory
  validates_format_of :object_type, :with => /User/
  validates_presence_of :object_id
end

class PageHistory::RevokedUserAccess < PageHistory
  validates_format_of :object_type, :with => /User/
  validates_presence_of :object_id
end

class PageHistory::AddComment < PageHistory
  validates_format_of :object_type, :with => /Post/
  validates_presence_of :object_id
end

class PageHistory::UpdateComment < PageHistory
  validates_format_of :object_type, :with => /Post/
  validates_presence_of :object_id
end

class PageHistory::DestroyComment < PageHistory
  validates_format_of :object_type, :with => /Post/
  validates_presence_of :object_id
end
