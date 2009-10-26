#
# Otherwise known as a group membership invitation, but sent
# to an email address and not a user.
#
# email: send the request to this address.
# recipient: set once the code is redeemed.
# requestable: the group
# created_by: person who sent the invite
#
class RequestToJoinUsViaEmail < Request

  validates_format_of :requestable_type, :with => /Group/
  validates_presence_of :email
  validates_as_email :email
  validates_length_of :code, :in => 6..8

  def recipient_required?() false end
  def group() requestable end

  def may_create?(user)
    user.may?(:admin,group)
  end

  # approve must be called after redeem
  def may_approve?(user)
    user == recipient
  end

  def may_destroy?(user)
    user.may?(:admin, group)
  end

  def may_view?(user)
    may_create?(user) or may_approve?(user)
  end

  # this assumes that the code has been redeemed and an account created
  # and that account is set to recipient.
  def after_approval
    group.add_user! recipient
  end

  def description
    "{email} was invited to join {group}"[:request_to_join_us_via_email_description, {
      :email => email, :group => group_span(group)
    }]
  end

  ##
  ## code handling
  ##

  def self.redeem_code!(user, code, email)
    request = find_by_code_and_email(code,email)
    if request
      if request.state != 'pending'
        raise ErrorMessage.new("Invite has already been redeemed"[:invite_error_redeemed])
      end
      request.recipient = user
      request.save!
      return request
    else
      raise ErrorNotFound.new("Invite"[:invite])
    end
  end

  before_validation_on_create :set_code
  def set_code
    self.code = Password.random(8)
  end

  #after_create :send_invite_code
  #def send_invite_code
  #  Mailer::Request.deliver_invite_code(self) if recipient && recipient.receives_email_on('messages')
  #end

end

