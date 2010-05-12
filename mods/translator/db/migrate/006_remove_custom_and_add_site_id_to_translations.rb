class RemoveCustomAndAddSiteIdToTranslations < ActiveRecord::Migration
  def self.up
    remove_column :translations, :custom
    add_column :translations, :site_id, :integer
  end

  def self.down
    add_column :translations, :custom, :boolean, :default => false
    remove_column :translations, :site_id
  end
end

