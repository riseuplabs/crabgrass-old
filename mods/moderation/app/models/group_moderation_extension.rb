module GroupModerationExtension

  def self.add_to_class_definition
    lambda do
      named_scope :moderated,
        :include => :profiles,
        :conditions => ["profiles.admins_may_moderate = (?)", true]
    end
  end

  module InstanceMethods
    def admins_moderate_content?
      self.profiles.public.admins_may_moderate?
    end

    def admins_moderate_content=(value)
      profile=self.profiles.public
      profile.admins_may_moderate = value
      profile.save
    end

    def user_ids_without_moderators
      ids = user_ids
      return ids unless site = Site.current
      ids -= site.moderation_group.try.user_ids
      return ids unless site.respond_to? :super_admin_group
      ids -= Site.current.super_admin_group.try.user_ids
    end
  end
end
