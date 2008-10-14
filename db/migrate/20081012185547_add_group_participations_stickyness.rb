class AddGroupParticipationsStickyness < ActiveRecord::Migration
  def self.up
    add_column :group_participations, :static, :boolean
    add_column :group_participations, :static_expires, :datetime
    add_column :group_participations, :static_expired, :boolean
  end

  def self.down
    remove_column :group_participations, :static
    remove_column :group_participations, :static_expires
    remove_column :group_participations, :static_expired
  end
end
