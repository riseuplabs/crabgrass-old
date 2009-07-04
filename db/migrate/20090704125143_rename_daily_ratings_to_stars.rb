class RenameDailyRatingsToStars < ActiveRecord::Migration
  def self.up
    rename_column :dailies, :ratings, :stars
  end

  def self.down
    rename_column :dailies, :stars, :ratings
  end
end
