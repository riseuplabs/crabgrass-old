class GroupGainedUserActivity < Activity

  validates_format_of :subject_type, :with => /Group/
  validates_format_of :object_type, :with => /User/
  validates_presence_of :subject_id
  validates_presence_of :object_id

  alias_attr :group, :subject
  alias_attr :user,  :object
  
  before_create :set_access
  def set_access
    if user.profiles.public.may_see_groups? and group.profiles.public.may_see_members?
      self.access = Activity::PUBLIC
    end
  end

  def description
    "{user} joined {group_type} {group}"[
      :activity_user_joined_group, {
        :user => user_span(:user),
        :group_type => group_class(:group),
        :group => group_span(:group)
      }
    ]
  end

  def icon
    'membership_add'
  end

end
