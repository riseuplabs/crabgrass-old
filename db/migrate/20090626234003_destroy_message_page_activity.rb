class DestroyMessagePageActivity < ActiveRecord::Migration
  def self.up
    Activity.delete_all "type = 'MessagePageActivity'"
    Activity.delete_all "type = 'MessageReplyActivity'"
  end

  def self.down
  end
end
