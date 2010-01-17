module GroupModerationExtension

  def self.add_to_class_definition
    lambda do
      named_scope :moderating,
        :include => :profiles,
        :conditions => ["profiles.admins_may_moderate = (?)", true]
      named_scope :moderated,
        :joins => 'JOIN profiles ON profiles.entity_id = groups.council_id AND
          profiles.entity_type = "Group"',
        :select => 'groups.*',
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
  end
end
