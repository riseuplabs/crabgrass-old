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

  def trash_all_by_foreign_id(foreign_id)
    self.update_all('deleted_at=now()',"foreign_id=#{foreign_id}")
  end

  def find_by_user_and_foreign(user_id, foreign_id)
    self.find(:first, :conditions => ["user_id=? and foreign_id=?", user_id, foreign_id], :order => 'created_at DESC')
  end

  def find_by_foreign_id(foreign_id)
    find(:first, :conditions => ['foreign_id=?',foreign_id])
  end

  def find_all_by_foreign_id(foreign_id)
    find(:all, :conditions => ['foreign_id=?',foreign_id])
  end

  named_scope :by_foreign_id, lambda {|foreign_id|
    { :conditions => ['foreign_id = ?', foreign_id] }
  }
  named_scope :by_user, lambda {|user|
    { :conditions => ['user_id = ?', user.id] }
  }

end
