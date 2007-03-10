class CreateUserParticipations < ActiveRecord::Migration
  def self.up
    create_table :user_participations do |t|
      t.column :page_id, :integer
      t.column :user_id, :integer
      t.column :message_count, :integer, :default => 0
      t.column :read_at, :datetime
      t.column :wrote_at, :datetime
      t.column :access, :integer
      t.column :watch, :boolean
      t.column :recommend, :boolean
      t.column :bookmarked, :boolean
      t.column :resolved, :boolean
    end
  end

  def self.down
    drop_table :user_participations
  end
end
