class AlterUserAndGroupTrackingColumns < ActiveRecord::Migration
  def self.up
    rename_column(:relationships, :viewed_at, :visited_at)
    add_column(:relationships, :total_visits, :integer, :default => 0)
    rename_column(:trackings, :user_id, :current_user_id)
    add_column(:trackings, :user_id, :integer)

    ##
    ## rails does not let you use timestamps.
    ## i want to use timestamps. they make time math easier, they take up less space.
    ## but no can do.
    ##

    change_column(:relationships, :visited_at, :datetime, :default => '1000-01-01 00:00:00', :null => false)
    change_column(:memberships, :visited_at, :datetime, :default => '1000-01-01 00:00:00', :null => false)

    #execute 'ALTER TABLE `memberships` MODIFY COLUMN `visited_at` TIMESTAMP  NOT NULL DEFAULT 0'
    #execute 'ALTER TABLE `relationships` MODIFY COLUMN `visited_at` TIMESTAMP  NOT NULL DEFAULT 0'
  end

  def self.down
    change_column(:memberships, :visited_at, :datetime)
    change_column(:relationships, :visited_at, :datetime)

    remove_column(:relationships, :total_visits)
    remove_column(:trackings, :user_id)
    rename_column(:trackings, :current_user_id, :user_id)
    rename_column(:relationships, :visited_at, :viewed_at)
  end
end
