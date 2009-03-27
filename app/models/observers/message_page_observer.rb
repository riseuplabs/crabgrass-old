# = MessagePageObserver
# creates an MessagePageActivity for the recipients of messages and replies.
class MessagePageObserver < ActiveRecord::Observer

  def after_save(message_page)
    message_page.users.each do |name|
      unless name == message_page.created_by
        # if you want only the first message to create an activity 
        # uncomment the following:
        # if activity = MessagePageActivity.find_page(message_page.id)
        #   key = activity.key
        # else
        #   key = rand(Time.now)
        # end
        key = rand(Time.now)
        MessagePageActivity.create!(:user => name,
                                    :other_user => message_page.created_by,
                                    :related_id => message_page.id,
                                    :key => key)
      end
    end
  end

end

