# = MessagePageObserver
# creates an MessagePageActivity for the recipients of messages and replies.
class MessagePageObserver < ActiveRecord::Observer

  def after_save(message_page)
    message_page.users.each do |user|
      unless user == message_page.updated_by
        # if you want only the first message to create an activity 
        # uncomment the following:
        # if activity = MessagePageActivity.find_page(message_page.id)
        #   key = activity.key
        # else
        #   key = rand(Time.now)
        # end
        key = rand(Time.now)
        if activity = MessagePageActivity.find_page(message_page.id) && post = message_page.discussion.posts.last
          MessageReplyActivity.create(:user => user,
                                      :other_user => post.user,
                                      :related_id => post.id,
                                      :key => key)
        else
          MessagePageActivity.create!(:user => user,
                                      :other_user => message_page.updated_by,
                                      :related_id => message_page.id,
                                      :key => key)
        end
      end
    end
  end

end

