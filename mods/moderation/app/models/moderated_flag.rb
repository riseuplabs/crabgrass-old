#
# this is a generic moderation model
#

class ModeratedFlag < ActiveRecord::Base

#  belongs_to :foreign, :polymorphic => true
  belongs_to :user

  def add(options={})
    self.update_attribute(:reason_flagged, options[:reason]) if options[:reason]
    self.update_attribute(:comment, options[:comment]) if options[:comment]
    self.save!
  end

  def self.trash_all_by_foreign_id(foreign_id)
    self.update_all('deleted_at=now()',"foreign_id=#{foreign_id}")
  end

  def user_login
    return "Unknown" if self.user.nil?
    return self.user.login
  end

  named_scope :by_foreign_id, lambda {|foreign_id|
    { :conditions => ['foreign_id = ?', foreign_id] }
  }
  named_scope :by_user, lambda {|user|
    { :conditions => ['user_id = ?', user.id] }
  }

end
