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

  named_scope :having_state, lambda { |state|
    {:conditions => [ "requests.state = ?", state]}
  }
  named_scope :appearing_as_state, lambda { |state|
    if state == 'pending'
      {:conditions => "state='pending' OR state='ignored'"}
    else
      {:conditions => [ "requests.state = ?", state]}
    end
  }
  named_scope :pending, :conditions => "state = 'pending'"
  named_scope :by_created_at, :order => 'created_at DESC'
  named_scope :by_updated_at, :order => 'updated_at DESC'
  named_scope :created_by, lambda { |user|
    {:conditions => {:created_by_id => user.id}}
  }
  named_scope :to_user, lambda { |user|
    {:conditions => ["(recipient_id = ? AND recipient_type = 'User') OR (recipient_id IN (?) AND recipient_type = 'Group')", user.id, user.group_ids]}
  }
  named_scope :to_group, lambda { |group|
    {:conditions => ['recipient_id = ? AND recipient_type = ?', group.id, 'Group']}
  }
  named_scope :from_group, lambda { |group|
    {:conditions => ['requestable_id = ? and requestable_type = ?', group.id, 'Group']}
  }

  before_validation_on_create :set_default_state
  def set_default_state
    self.state = "pending" # needed despite FSM so that validations on create will work.
  end

  def validate
    unless may_create?(created_by)
      errors.add_to_base('Permission denied'.t)
    end
  end

  # state one of 'approved' 'rejected' or 'ignore'
  # user the person doing the change
  def set_state!(newstate, user)
    # reject unless we know the state
    commands = Hash.new('reject')
    commands['approved'] = 'approve'
    commands['ignored'] = 'ignore'

    command = commands[newstate]

    if new_record?
      raise Exception.new('record must be saved first')
    end

    self.approved_by = user
    self.send(command + '!') # FSM call, eg approve!()

    unless self.state == newstate
      raise PermissionDenied.new("%s is not allowed to #{command} the request.".t % user.name)
    end
    save!
  end


  def approve_by!(user)
    set_state!('approved',user)
  end

  def reject_by!(user)
    set_state!('rejected',user)
  end

  def ignore_by!(user)
    set_state!('ignored',user)
  end

  # triggered by FSM
  def approval_allowed()
    may_approve?(approved_by)
  end

  ##
  ## to be overridden by subclasses
  ##

  def description() end

  def may_create?(user)  false end
  def may_destroy?(user) false end
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
    transitions :from => :ignored,  :to => :rejected, :guard => :approval_allowed
  end
  event :ignore do
    transitions :from => :pending,  :to => :ignored,  :guard => :approval_allowed
  end

  ##
  ## MISC
  ##
  
  # used by subclass's description()
  # if you change this to display_name, make sure to escape it!
  def user_span(user)
    '<span class="user">%s</span>' % user.name
  end
  def group_span(group)
    '<span class="group">%s</span>' % group.name
  end

  # destroy all requests relating to this user
  def self.destroy_for_user(user)
    destroy_all ['created_by_id = ?', user.id]
    destroy_all ["recipient_id = ? AND recipient_type = 'User'", user.id]
  end
 
  # destroy all requests relating to this group
  def self.destroy_for_group(group)
    destroy_all ["recipient_id = ? AND recipient_type = 'Group'", group.id]
    destroy_all ["requestable_id = ? AND requestable_type = 'Group'", group.id]
  end

end

