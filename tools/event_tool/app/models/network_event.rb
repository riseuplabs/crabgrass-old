class NetworkEvent < ActiveRecord::Base
  belongs_to :modified, :polymorphic => true
  belongs_to :user
  serialize :data_snapshot

  validates_presence_of :modified_id
  validates_presence_of :user_id
  validates_presence_of :action


  attr_accessor :recipients

  after_create :send_notifications
  def send_notifications
    @notices = Notification.create recipients.map{ |user| { :user => user, :network_event => self} } if recipients
  end
end
