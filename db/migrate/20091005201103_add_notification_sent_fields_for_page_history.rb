class AddNotificationSentFieldsForPageHistory < ActiveRecord::Migration
  def self.up
    add_column :page_histories, :notification_sent_at, :datetime
    add_column :page_histories, :notification_digest_sent_at, :datetime
  end

  def self.down
    remove_column :page_histories, :notification_sent_at
    remove_column :page_histories, :notification_digest_sent_at
  end
end
