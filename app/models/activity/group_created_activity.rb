class GroupCreatedActivity < Activity

  validates_format_of :subject_type, :with => /Group/
  validates_presence_of :subject_id

  alias_attr :group, :subject
  alias_attr :user,  :object
  
  def description
    "{user} created {group_type} {group}"[
      :activity_group_created, {
        :user => user_span(:user),
        :group_type => group_class(:group),
        :group => group_span(:group)
      }
    ]
  end

  def icon
    'plus'
  end

end
