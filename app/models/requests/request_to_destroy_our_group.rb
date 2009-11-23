#
# An a group member requests to delete their group. this creates a proposal that others vote on
#
# recipient: the group to be destroyed
# requestable: the same group
# created_by: person in group who want their group to be destroyed
#
class RequestToDestroyOurGroup < Request
  validates_format_of :recipient_type, :with => /Group/
  validates_format_of :requestable_type, :with => /Group/


  named_scope :for_group, lambda { |group|
    { :conditions => {:recipient_id => group.id},
      :conditions => {:requestable_id => group.id}}
  }


  def validate_on_create
    if RequestToDestroyOurGroup.for_group(@group).created_by(current_user).find(:first)
      errors.add_to_base(I18n.t(:request_exists_error, :recipient => group.display_name))
    end
  end

  def group() recipient end

  def may_create?(user)
    user.may?(:admin, group)
  end

  def may_approve?(user)
    user.may?(:admin, group)
  end

  def may_destroy?(user)
    created_by == user
  end

  def may_view?(user)
    may_create?(user) or may_approve?(user)
  end

  def after_approval
    group.destroy
  end

  def description
    I18n.t(:request_to_destroy_our_group_description,  :group => group_span(group), :user => user_span(created_by))
  end

end