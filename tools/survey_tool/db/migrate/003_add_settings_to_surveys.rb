class AddSettingsToSurveys < ActiveRecord::Migration
  def self.up
    add_column :surveys, :settings, :string
  end

  def self.down
    remove_column :surveys, :settings
  end
end
