class CreateAvatars < ActiveRecord::Migration
  def self.up
    create_table :avatars do |t|
      t.column :data, :binary, :size => 65535, :null => false
      t.column :viewable_id, :integer
	  t.column :viewable_type, :string
    end
    execute "ALTER TABLE `avatars` MODIFY `data` BLOB"
  end

  def self.down
    drop_table :avatars
  end
end
