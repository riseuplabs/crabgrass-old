class ModifyFeaturedPages < ActiveRecord::Migration
  def self.up
    remove_column :pages, :static
    remove_column :pages, :static_expires
    remove_column :pages, :static_expired

    add_column :group_participations, :featured_position, :integer

    # UPDATE `group_participations` SET featured_position = id WHERE (static = 1) 
    GroupParticipation.update_all 'featured_position = id', 'static = 1'
  end

  def self.down
    add_column :pages, :static, :boolean
    add_column :pages, :static_expires, :datetime
    add_column :pages, :static_expired, :boolean

    remove_column :group_participations, :featured_position
  end
end
