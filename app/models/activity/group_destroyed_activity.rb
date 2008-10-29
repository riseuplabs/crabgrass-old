class GroupDestroyedActivity < Activity

  validates_format_of :subject_type, :with => /User/
  validates_presence_of :subject_id
  validates_presence_of :extra

  alias_attr :recipient,     :subject
  alias_attr :destroyed_by,  :object
  alias_attr :groupname,     :extra

  def description
    "{group} was destroyed by {user}"[:activity_group_destroyed, {
       :user => user_span(:destroyed_by),
       :group => groupname
    }]
  end

  def icon
    'minus'
  end

end

