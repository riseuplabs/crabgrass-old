class FriendActivity < Activity

  validates_format_of :subject_type, :with => /User/
  validates_format_of :object_type, :with => /User/
  validates_presence_of :subject_id
  validates_presence_of :object_id

  alias_attr :user,       :subject
  alias_attr :other_user, :object
  
  before_create :set_access
  def set_access
    unless user.profiles.private.may_see_contacts?
      self.access = Activity::PRIVATE
    end
  end

  def description
    "{user} added {other_user} as a contact"[
       :activity_contact_created, 
       {:user => user_span(:user), :other_user => user_span(:other_user)}
    ]
  end

  def self.find_twin(user, other_user)
    find(:first, :conditions => ['subject_id = ? AND object_id = ?', other_user.id, user.id])
  end

  def icon
    'user_add'
  end

end

