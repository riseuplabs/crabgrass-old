class UserDestroyedActivity < Activity

  validates_format_of :subject_type, :with => /User/
  validates_presence_of :subject_id
  validates_presence_of :extra

  alias_attr :recipient,  :subject
  alias_attr :username,   :extra

  def description
    "{user} has retired"[
       :activity_user_destroyed, {:user => username}
    ]
  end

  def icon
    'minus'
  end

end

