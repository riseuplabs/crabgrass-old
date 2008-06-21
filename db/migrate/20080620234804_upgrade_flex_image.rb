=begin

  The new version of Fleximage has it hardcoded what the name of the column
  must be if you are storing images in the database. Weird.
  
  In the long run, we should not be storing images in the database anyway.
  For now, we will change the name of the column to match what Fleximage needs

=end

class UpgradeFlexImage < ActiveRecord::Migration
  def self.up
    rename_column :avatars, :data, :image_file_data
  end

  def self.down
    rename_column :avatars, :image_file_data, :data
  end
end
