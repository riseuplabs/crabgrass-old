=begin
    create_table "requests", :force => true do |t|
      t.integer  "created_by_id"
      t.integer  "approved_by_id"

      t.integer  "recipient_id"
      t.string   "recipient_type", :limit => 5

      t.string   "email"
      t.string   "code", :limit => 8

      t.integer  "requestable_id"
      t.string   "requestable_type", :limit => 10

      t.integer  "shared_discussion_id"
      t.integer  "private_discussion_id"

      t.string   "state", :limit => 10
      t.string   "type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
=end

#
# Anytime an action needs approval, a Request is made.
# This includes invitations, requests to join, RSVP, etc. 
# 
class Request < ActiveRecord::Base

  belongs_to :created_by, :class_name => 'User'
  belongs_to :approved_by, :class_name => 'User'

  belongs_to :recipient, :polymorphic => true
  belongs_to :requestable, :polymorphic => true  

  belongs_to :shared_discussion, :class_name => 'Discussion'
  belongs_to :private_discussion, :class_name => 'Discussion'

  validates_presence_of :created_by_id
  validates_presence_of :recipient_id,   :if => :recipient_required?
  validates_presence_of :requestable_id, :if => :requestable_required?

  named_scope :pending, :conditions => [ "requests.state = ? OR messages.state IS NULL", "pending" ]
  named_scope :by_created_at, :order => 'created_at DESC'
  named_scope :by_updated_at, :order => 'updated_at DESC'

  def validate
    unless may_create?(created_by)
      errors.add_to_base('Permission denied'.t)
    end
  end

  def approve_by!(user)
    if new_record?
      raise Exception.new('record must be saved first')
    end

    self.approved_by = user
    approve! # FSM call

    unless state == 'approved'
      raise PermissionDenied.new('%s is not allowed to approve the request.'.t % user.name)
    end
    save!
  end

  def reject_by!(user)
    self.approved_by = user
    reject! # FSM call
    save!
  end

  # triggered by FSM
  def approval_allowed()
    may_approve?(approved_by)
  end

  ##
  ## to be overridden by subclasses
  ##

  def may_create?(user)  false end
  def may_approve?(user) false end
  def may_view?(user)    false end

  def after_approval() end

  def recipient_required?()   true end
  def requestable_required?() true end

  ##
  ## finite state machine
  ## 
  ## There’s a time when the operation of the machine becomes so odious, makes
  ## you so sick at heart, that you can't take part, you can’t even passively
  ## take part, and you’ve got to put your bodies upon the gears and upon the
  ## wheels, upon the levers, upon all the apparatus, and you’ve got to make it
  ## stop! And you’ve got to indicate to the people who run it, to the people
  ## who own it, that unless you’re free, the machine will be prevented from
  ## working at all! --Mario Savio
  ## 

  acts_as_state_machine :initial => :pending
  state :pending
  state :approved, :after => :after_approval
  state :rejected
  state :ignored

  event :approve do
    transitions :from => :pending,  :to => :approved, :guard => :approval_allowed
    transitions :from => :rejected, :to => :approved, :guard => :approval_allowed
    transitions :from => :ignored,  :to => :approved, :guard => :approval_allowed
  end
  event :reject do
    transitions :from => :pending,  :to => :rejected, :guard => :approval_allowed
  end
  event :ignore do
    transitions :from => :pending,  :to => :ignored,  :guard => :approval_allowed
  end

#  after_create :notify_recipient
#  def notify_recipient
#    UserMailer.deliver_message_received(self) if recipient && recipient.receives_email_on('messages')
#  end
end

