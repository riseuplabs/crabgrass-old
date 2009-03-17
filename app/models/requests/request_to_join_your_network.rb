#
# An outside user requests for their group to be part of a network. 
#
# recipient: the network
# requestable: the group
# created_by: person in group who want their group in the network
#
class RequestToJoinYourNetwork < Request
  
  validates_format_of :recipient_type, :with => /Group/
  validates_format_of :requestable_type, :with => /Group/
  
  def validate_on_create
    unless recipient.type =~ /Network/
      errors.add_to_base('recipient must be a network')
    end
    if Federating.find_by_group_id_and_network_id(group.id, network.id)
      errors.add_to_base('Membership already exists for %s'[:membership_exists_error] % group.name)
    end
    if RequestToJoinYourNetwork.appearing_as_state(state).find_by_recipient_id_and_requestable_id_and_state(recipient_id, requestable_id, state)
      errors.add_to_base('Request already exists for %s'[:request_exists_error] % group.name)
    end
  end

  def group() requestable end
  def network() recipient end
  
  def may_create?(user)
    user.may?(:admin,group)
  end

  def may_approve?(user)
    user.may?(:admin,network)
  end

  def may_destroy?(user)
    may_view?(user)
  end

  def may_view?(user)
    may_create?(user) or may_approve?(user)
  end

  def after_approval
    network.add_group!(group)
  end

  def description
    ":group requested to join network :network"[:request_to_join_your_network_description] % {
      :group => group_span(group), :network => group_span(network)
    }
  end

end

