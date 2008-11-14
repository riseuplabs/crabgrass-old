class AddCustomToTranslations < ActiveRecord::Migration
  def self.up
    add_column :translations, :custom, :boolean, :default => false
  end

  def self.down
    remove_column :translations, :custom
  end
end
