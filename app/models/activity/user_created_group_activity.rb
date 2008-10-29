class UserCreatedGroupActivity < Activity

  validates_format_of :subject_type, :with => /User/
  validates_format_of :object_type, :with => /Group/
  validates_presence_of :subject_id
  validates_presence_of :object_id

  alias_attr :user,  :subject
  alias_attr :group, :object
  
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
