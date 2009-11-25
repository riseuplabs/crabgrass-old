#
# this is a generic moderation model
#

class ModeratedFlag < ActiveRecord::Base

#  belongs_to :foreign, :polymorphic => true
  belongs_to :user

  def add(options={})
    update_attribute(:reason_flagged, options[:reason]) if options[:reason]
    update_attribute(:comment, options[:comment]) if options[:comment]
    self.save!
  end

  def self.trash_all_by_foreign_id(foreign_id)
    update_all('deleted_at=now()',"foreign_id=#{foreign_id}")
  end

  def user_login
    return "Unknown" if user.nil?
    return user.login
  end

  ### don't these seem awfully repetitious? ;-)
  def approve
    foreign.update_attribute(:vetted, true)
    update_all_flags('vetted_at=now()')
  end

  def trash
    foreign.delete
    update_all_flags('deleted_at=now()')
  end

  def undelete
    foreign.undelete
    update_all_flags('deleted_at=NULL')
  end
  ### end awfully repetitious


  def self.conditions_for_view(view)
    case view
    when 'new'
      then 'moderated_flags.vetted_at IS NULL and moderated_flags.deleted_at IS NULL'
    when 'vetted'
      then 'moderated_flags.vetted_at IS NOT NULL and moderated_flags.deleted_at IS NULL'
    when 'deleted'
      then 'moderated_flags.deleted_at IS NOT NULL'
    end
  end

  def self.display_flags(page, view)
    conditions = [conditions_for_view(view)]
    return if conditions.empty?
    paginate(:page => page, :select => "distinct foreign_id",
             :conditions => conditions, :order => 'updated_at DESC')
  end

  named_scope :by_foreign_id, lambda {|foreign_id|
    { :conditions => ['foreign_id = ?', foreign_id] }
  }
  named_scope :by_user, lambda {|user|
    { :conditions => ['user_id = ?', user.id] }
  }

  protected

  def update_all_flags(update_string)
    ModeratedFlag.update_all(update_string, "foreign_id=#{foreign_id} and type='#{type}'")
  end

end
