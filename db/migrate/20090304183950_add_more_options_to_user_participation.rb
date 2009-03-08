class AddMoreOptionsToUserParticipation < ActiveRecord::Migration
  def self.up

    add_column :user_participations, :mail, :boolean
    add_column :user_participations, :mail_options, :string
    add_column :user_participations, :chat, :boolean
    add_column :user_participations, :chat_options, :string
    add_column :user_participations, :inbox_options, :string
  end

  def self.down
    remove_column :user_participations, :mail
    remove_column :user_participations, :mail_options
    remove_column :user_participations, :chat_options
    remove_column :user_participations, :chat
    remove_column :user_participations, :inbox_options
  end
end
