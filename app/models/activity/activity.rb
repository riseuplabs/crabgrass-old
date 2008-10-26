class Activity < ActiveRecord::Base

  belongs_to :subject, :polymorphic => true
  belongs_to :object, :polymorphic => true

  def before_create
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
  ## FINDERS
  ##

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
      "(subject_type = 'User'  AND subject_id IN (?)) OR
       (subject_type = 'Group' AND subject_id IN (?))",
      [current_user.id] + current_user.friend_id_cache,
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
    if current_user and current_user.friend_of?(user)
      {:conditions => [
        "subject_type = 'User' AND subject_id = ?", user.id
      ]}
    else
      {:conditions => [
        "public = ? AND (subject_type = 'User' AND subject_id = ?)",
        true, user.id
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
        "subject_type = 'Group' AND subject_id IN (?)", group.group_and_committee_ids
      ]}
    else
      {:conditions => [
        "public = ? AND (subject_type = 'Group' AND subject_id IN (?))",
        true, group.group_and_committee_ids
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
      define_method("#{new}_name") { read_attribute("#{old}_name") }
      define_method("#{new}_type") { read_attribute("#{old}_type") }
    else
      define_method(new) { read_attribute(old) }
      define_method("#{new}=") { |value| write_attribute(old, value) }
    end
  end

end

