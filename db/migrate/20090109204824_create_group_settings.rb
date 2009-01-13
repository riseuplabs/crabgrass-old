class CreateGroupSettings < ActiveRecord::Migration
  def self.up
    create_table :group_settings do |t|
      t.integer :group_id
      t.string :template_data
      t.string :allowed_tools   
    end
    
    Group.find(:all).each do |g|
      g.group_setting = GroupSetting.new
      g.group_setting.save
    end
  end

  def self.down
    drop_table :group_settings
  end
end
