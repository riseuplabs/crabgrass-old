class ConvertTextToText < ActiveRecord::Migration
  def self.up
    change_column :translations, :text, :text
  end

  def self.down
    change_column :translations, :text, :string
  end
end

