class RenameHourlyRatingsToStars < ActiveRecord::Migration
  def self.up
    rename_column :hourlies, :ratings, :stars
  end

  def self.down
    rename_column :hourlies, :stars, :ratings
  end
end
