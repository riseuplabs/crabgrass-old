class GroupGainedUserActivity < Activity

  validates_format_of :subject_type, :with => /Group/
  validates_format_of :object_type, :with => /User/
  validates_presence_of :subject_id
  validates_presence_of :object_id

  alias_attr :group, :subject
  alias_attr :user,  :object
  
  def description
    "{user} joined {group_type} {group}"[
      :activity_user_joined_group, {
        :user => user_span(:user),
        :group_type => group_class(:group),
        :group => group_span(:group)
      }
    ]
  end

end
