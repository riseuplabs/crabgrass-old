class CreateAvatars < ActiveRecord::Migration
  def self.up
    create_table :avatars do |t|
      t.column :data, :binary, :limit => 65535, :null => false
      t.column :public, :boolean, :default => false
    end
  end

  def self.down
    drop_table :avatars
  end
end
