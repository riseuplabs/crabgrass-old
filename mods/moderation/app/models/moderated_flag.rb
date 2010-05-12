#
# this is a generic moderation model
#

class ModeratedFlag < ActiveRecord::Base

  belongs_to :flagged, :polymorphic => true
  belongs_to :user

  def add(options={})
    update_attribute(:reason_flagged, options[:reason]) if options[:reason]
    update_attribute(:comment, options[:comment]) if options[:comment]
    self.save!
  end

  def self.trash_all_by_flagged(entity)
    update_all 'deleted_at=now()',
      "flagged_id=#{entity.id}, flagged_type=#{entity.type}"
  end

  def user_login
    return "Unknown" if user.nil?
    return user.login
  end

  ### don't these seem awfully repetitious? ;-)
  def approve
    flagged.update_attribute(:vetted, true)
    update_all_flags('vetted_at=now()')
  end

  def trash
    flagged.delete
    update_all_flags('deleted_at=now()')
  end

  def undelete
    flagged.undelete
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
    paginate(:page => page, :select => "distinct flagged_id",
             :conditions => conditions, :order => 'updated_at DESC')
  end

  named_scope :by_flagged, lambda {|flagged|
    { :conditions => {:flagged => flagged} }
  }
  named_scope :by_user, lambda {|user|
    { :conditions => {:user => user} }
  }

  protected

  def update_all_flags(update_string)
    ModeratedFlag.update_all(update_string, "flagged_id=#{flagged_id} and flagged_type='#{flagged_type}'")
  end

end
