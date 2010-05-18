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
        sender.send_message_to!(receiver, text)
      end
      page.destroy

    end

  end

  def self.down
  end
end
