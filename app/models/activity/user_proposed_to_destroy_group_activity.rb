class UserProposedToDestroyGroupActivity < Activity
  validates_format_of :subject_type, :with => /User/
  validates_format_of :object_type, :with => /Group/
  validates_presence_of :subject_id
  validates_presence_of :object_id

  alias_attr :user,  :subject
  alias_attr :group, :object

  before_create :set_access
  def set_access
    if user.profiles.public.may_see_groups? and group.profiles.public.may_see_members?
      self.access = Activity::PUBLIC
    end
  end


  def description(view=nil)
    I18n.t(:request_to_destroy_our_group_description,
              :user => user_span(:user),
              :group_type => group_class(:group),
              :group => group_span(:group))
  end

  def icon
    'minus'
  end


end

