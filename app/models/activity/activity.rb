# = Activity
# Activities are used to populate the recent activity list on the dashboard.
# They are usually created by Observers on the corresponding object.
# Activities will show up on the subjects landing page.
#
# == Database Schema:
#
#  create_table "activities", :force => true do |t|
#    t.integer  "subject_id",   :limit => 11
#    t.string   "subject_type"
#    t.string   "subject_name"
#    t.integer  "object_id",    :limit => 11
#    t.string   "object_type"
#    t.string   "object_name"
#    t.string   "type"
#    t.string   "extra"
#    t.integer  "related_id",
#    t.integer  "key",          :limit => 11
#    t.datetime "created_at"
#    t.integer  "access",       :limit => 1,  :default => 2
#  end
#
#
# related_id and extra are used for generic storage and association, whatever 
# the subclass wants to use it for.
# 

class Activity < ActiveRecord::Base

  # activity access:
  PRIVATE = 1  # only you can see it
  DEFAULT = 2  # your friends can see it activity for you
  PUBLIC  = 3  # anyone can see it.

  belongs_to :subject, :polymorphic => true
  belongs_to :object, :polymorphic => true

  before_create :set_defaults
  def set_defaults # :nodoc:
    # the key is used to filter out twin activities so that we don't show
    # duplicates. for example, if two of your friends become friends, you don't
    # need to know about it twice. 
    self.key ||= rand(Time.now)

    # sometimes the subject or object may be deleted. 
    # therefor, we cache the name in case the subject or object doesn't exist.
    self.subject_name ||= self.subject.name if self.subject and self.subject.respond_to?(:name)
    self.object_name  ||= self.object.name if self.object and self.object.respond_to?(:name)
  end

  # to be defined by subclases
  def icon() end

  # to be defined by subclases
  def description(options={}) end

  #--
  ## FINDERS
  #++

  named_scope :newest, {:order => 'created_at DESC', :limit => 10}

  named_scope :unique, {:group => '`key`'}
  
  # for current_user's dashboard
  #
  # show all activity for:
  #
  # (1) subject is current_user
  # (2) subject is friend of current_user
  # (3) subject is a group current_user is in. 
  #
  named_scope :for_dashboard, lambda {|current_user|
    {:conditions => [
      "(subject_type = 'User'  AND subject_id = ?) OR
       (subject_type = 'User'  AND subject_id IN (?) AND access != ?) OR
       (subject_type = 'Group' AND subject_id IN (?))",
      current_user.id, current_user.friend_id_cache, Activity::PRIVATE,
      current_user.all_group_id_cache
    ]}
  }

  # for user's landing page
  #
  # show all activity for:
  #
  # (1) subject matches 'user'
  #     (AND 'user' is friend of current_user)
  #
  # (2) subject matches 'user'
  #     (AND activity.public == true)
  #
  named_scope :for_user, lambda {|user, current_user|
    if current_user and (current_user.friend_of?(user) or current_user == user)
      {:conditions => [
        "subject_type = 'User' AND subject_id = ? AND access != ?",
        user.id, Activity::PRIVATE
      ]}
    else
      {:conditions => [
        "subject_type = 'User' AND subject_id = ? AND access = ?",
        user.id, Activity::PUBLIC
      ]}
    end
  }

  # for group's landing page
  #
  # show all activity for:
  #
  # (1) subject matches 'group'
  #     (and current_user is a member of group)
  #
  # (2) subject matches 'group'
  #     (and activity.public == true)
  #
  named_scope :for_group, lambda {|group, current_user|
    if current_user and current_user.member_of?(group)
      {:conditions => [
        "subject_type = 'Group' AND subject_id IN (?)",
        group.group_and_committee_ids
      ]}
    else
      {:conditions => [
        "subject_type = 'Group' AND subject_id IN (?) AND access = ?",
        group.group_and_committee_ids, Activity::PUBLIC
      ]}
    end
  }


  ##
  ## DISPLAY HELPERS
  ##

  # used by subclass's description()
  # if you change this to display_name, make sure to escape it!

  def thing_span(thing, type)
    object = self.send(thing)
    if object
      name = object.name
    else 
      name = self.send(thing.to_s + '_name')
      name ||= 'unknown'.t
    end
    '<span class="%s">%s</span>' % [type,name]
  end
  def group_span(attribute)
    thing_span(attribute, 'group')
  end
  def user_span(attribute)
    thing_span(attribute, 'user')
  end
  def group_class(attribute)
    if group = self.send(attribute)
      group.display_type().t
    elsif group_type = self.send(attribute.to_s + '_type')
      group_type.downcase.t
    end
  end
  
  ##
  ## DYNAMIC MAGIC
  ##

  def self.alias_attr(new, old)
    if self.method_defined? old
      alias_method new, old
      alias_method "#{new}=", "#{old}="
      define_method("#{new}_id")   { read_attribute("#{old}_id") }
      define_method("#{new}_name") { read_attribute("#{old}_name") }
      define_method("#{new}_type") { read_attribute("#{old}_type") }
    else
      define_method(new) { read_attribute(old) }
      define_method("#{new}=") { |value| write_attribute(old, value) }
    end
  end

end

