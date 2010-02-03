class AlterAvatarsIncreaseImageFileDataLimit < ActiveRecord::Migration
  def self.up
    change_column :avatars, :image_file_data, :binary, :limit => 16777217, :default => nil
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
