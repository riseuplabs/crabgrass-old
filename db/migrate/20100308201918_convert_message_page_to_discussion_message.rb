class ConvertMessagePageToDiscussionMessage < ActiveRecord::Migration
  # MessagePage class has been deleted a while ago,
  # define it with :: to make it top namespace
  class ::MessagePage < ::Page
  end

  def self.up
    pages = MessagePage.all

    pages.each do |page|
      next if page.users.count < 2

      page.discussion.try.posts.each do |post|
        text = post.body
        sender = post.user
        receiver = page.users.detect {|u| u != sender}


        next if sender.blank? || receiver.blank? || text.blank?

        # create the new message
        new_post = sender.send_message_to!(receiver, text)

        disable_timestamps
        new_post.update_attributes({:updated_at => post.updated_at, :created_at => post.created_at})
        enable_timestamps
      end
      page.destroy

    end

  ensure
    enable_timestamps
  end

  def self.down
  end

  protected

  def self.disable_timestamps
    PrivatePost.record_timestamps = false
    Post.record_timestamps = false
  end

  def self.enable_timestamps
    PrivatePost.record_timestamps = true
    Post.record_timestamps = true
  end

end
