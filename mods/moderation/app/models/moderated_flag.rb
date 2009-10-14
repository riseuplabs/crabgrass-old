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

  def self.display_flags(page, view)
    if view == 'new'
      conditions = ['vetted_at IS NULL and deleted_at IS NULL']
    elsif view == 'vetted'
      conditions = ['vetted_at IS NOT NULL and deleted_at IS NULL']
    elsif view == 'deleted'
      conditions = ['deleted_at IS NOT NULL']
    else
      return
    end
    paginate(:page => page, :select => "distinct foreign_id", :conditions => conditions, :order => 'updated_at DESC')
  end

  named_scope :by_foreign_id, lambda {|foreign_id|
    { :conditions => ['foreign_id = ?', foreign_id] }
  }
  named_scope :by_user, lambda {|user|
    { :conditions => ['user_id = ?', user.id] }
  }

end
