class ChangeProfileBirthdayTypeToDatetime < ActiveRecord::Migration
  def self.up
    change_column :profiles, :birthday, :datetime
  end

  def self.down
    change_column :profiles, :birthday, :string
  end
end
