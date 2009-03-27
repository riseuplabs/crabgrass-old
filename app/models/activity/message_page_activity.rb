# MessagePageActivity
#
# This activity lists messages that have been received.
# That is: :user recieved_message from :other_user.
# So the recipient is the :subject because we want to list
# messages that have been recieved not the messages we have
# send.
#
# The access level is private so that only the recipient 
# can see the activity.
class MessagePageActivity < Activity
  include ActionView::Helpers::TagHelper

  validates_format_of :subject_type, :with => /User/
  validates_format_of :object_type, :with => /User/
  validates_presence_of :subject_id
  validates_presence_of :object_id
  validates_presence_of :related_id

  alias_attr :user,       :subject
  alias_attr :other_user, :object
  alias_attr :message_id,  :related_id
  
  before_create :set_access
  def set_access # :nodoc:
    # We only show messages to the people who received them.
    self.access = Activity::PRIVATE
  end

  # returns a string to display in the activity feed. 
  # contains a links to the message and the sender.
  def description(options={})
    # since the access is PRIVATE we know user is current_user.
    begin
      page=Page.find(self.message_id)
    rescue ActiveRecord::RecordNotFound
      return "You received {message_tag} from {other_user}: {title}"[
       :activity_message_received,
       {:message_tag => "a message",
        :other_user => user_span(:other_user),
        :title => ""}
      ]
    end
      page_link = content_tag(:a,'a message'[:a_message_link],
                             :href => "/#{page.owner_name}/#{page.friendly_url}")
      title = content_tag(:span,page.title,:class => 'message')
      return "You received {message_tag} from {other_user}: {title}"[
       :activity_message_received,
       {:message_tag => page_link,
        :other_user => user_span(:other_user),
        :title => title}
      ]
  end

  # used to identify if an activity has been created for the discussion
  # before.
  def self.find_page(id)
    find(:first, :conditions => ['related_id = ?', id])
  end

  def icon # :nodoc:
    'page_message'
  end

end

