class AddMediaFlagsAndPageTermsToAssets < ActiveRecord::Migration
  def self.up
    add_column :page_terms, :media, :string

    add_column :assets, :page_terms_id, :integer
    add_column :assets, :is_attachment, :boolean, :default => false
    add_column :assets, :is_image, :boolean
    add_column :assets, :is_audio, :boolean
    add_column :assets, :is_video, :boolean
    add_column :assets, :is_document, :boolean
    add_column :assets, :updated_at, :datetime

    add_index :assets, ["page_terms_id"], :name => "pterms"
    
    ThinkingSphinx.updates_enabled = false
    ActiveRecord::Base.record_timestamps = false
    Asset.reset_column_information

    AssetPage.find(:all).each do |page|
      asset = page.data
      terms = page.page_terms
      next unless page.data and page.data.is_a? Asset
      asset.update_media_flags
      asset.page_terms = terms
      asset.is_attachment = true if asset.page_id
      asset.save_without_revision!
      page.custom_page_terms(terms)
      terms.save!
    end
  end

  def self.down
    remove_column :page_terms, :media
    remove_column :assets, :page_terms_id
    remove_column :assets, :is_attachment
    remove_column :assets, :is_image
    remove_column :assets, :is_audio
    remove_column :assets, :is_video
    remove_column :assets, :is_document
  end
end

