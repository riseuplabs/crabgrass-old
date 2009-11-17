# = Activity
#
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
#    t.integer  "site_id",      :limite => 11
#  end
#
#
# related_id and extra are used for generic storage and association, whatever
# the subclass wants to use it for.
#

class Activity < ActiveRecord::Base

  # activity access (relative to self.subject):
  PRIVATE = 1  # only you can see it
  DEFAULT = 2  # your friends can see this activity for you
  PUBLIC  = 3  # anyone can see it.

  belongs_to :subject, :polymorphic => true
  belongs_to :object, :polymorphic => true

  acts_as_site_limited

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

  ##
  ## ACTIVITY DISPLAY
  ##

  # to be defined by subclasses
  def icon()
    'exclamation'
  end

  # to be defined by subclasses
  def style()
  end

  # to be defined by subclasses
  def description(view) end

  # to be defined by subclasses
  def link() end

  # calls description, and if there is any problem, then we self destruct.
  # why? because activities hold pointers to all kinds of objects. These can be
  # deleted at any time. So if there is an error, it is probably because we
  # tried to reference a deleted record.
  #
  # (normally, groups and users will not cause a problem, because most the time
  # we cache their name's at the time of the activity's creation)
  def safe_description(view=nil)
    description(view)
  rescue
    self.destroy
    nil
  end

  ##
  ## FINDERS
  ##

  named_scope :newest, {:order => 'created_at DESC'}

  named_scope :unique, {:group => '`key`'}

  ### I DON'T THINK THIS IS NEEDED
  ### you should be able to resolve this when the activity is created.
  named_scope :only_visible_groups,
    {:joins => "LEFT JOIN profiles ON
      object_type <=> 'Group' AND
      profiles.entity_type <=> 'Group' AND
      profiles.entity_id <=> object_id AND
      profiles.stranger = TRUE",
    :conditions => "NOT profiles.may_see <=> FALSE",
    :select => "activities.*",
  }

  # for user's dashboard
  #
  # show all activity for:
  #
  # (1) subject is current_user
  # (2) subject is friend of current_user
  # (3) subject is a group current_user is in.
  # (4) take the intersection with the contents of site if site.network.nil?
  named_scope(:for_dashboard, lambda do |user|
    {:conditions => [
      "(subject_type = 'User'  AND subject_id = ?) OR
       (subject_type = 'User'  AND subject_id IN (?) AND access != ?) OR
       (subject_type = 'Group' AND subject_id IN (?)) ",
      user.id,
      user.friend_id_cache,
      Activity::PRIVATE,
      user.all_group_id_cache]
    }
  end)

  # for user's landing page
  #
  # show all activity for:
  #
  # (1) subject matches 'user'
  #     (AND 'user' is friend of current_user) 
  #
  # (3) subject matches 'user'
  #     (AND activity.public == true)
  #
  named_scope(:for_user, lambda do |user, current_user|
    if (current_user and current_user.friend_of?(user) or current_user == user) 
      restricted = Activity::PRIVATE
    elsif current_user and current_user.peer_of?(user) 
      restricted = Activity::DEFAULT
    else 
      restricted = Activity::DEFAULT
    end
    {:conditions => [
      "subject_type = 'User' AND subject_id = ? AND access > ?",
      user.id, restricted 
    ]}
  end)

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
  named_scope(:for_group, lambda do |group, current_user|
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
  end)

  ##
  ## DISPLAY HELPERS
  ##
  ## used by the description() method of Activity subclasses
  ##

  # a safe way to reference a group, even if the group has been deleted.
  def group_span(attribute)
    thing_span(attribute, 'group')
  end

  # a safe way to reference a user, even if the group has been deleted.
  def user_span(attribute)
    thing_span(attribute, 'user')
  end

  def group_class(attribute)
    if group = self.send(attribute)
      group.group_type.downcase
    elsif group_type = self.send(attribute.to_s + '_type')
      I18n.t(group_type.downcase.to_sym).downcase
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

  private

  # often, stuff that we want to report activity on has already been
  # destroyed. so, if the thing responds to :name, we cache the name.
  def thing_span(thing, type)
    name = self.send("#{thing}_name") || self.send(thing).try.name || I18n.t(:unknown)
    '<span class="%s">%s</span>' % [type, name]
  end

end

