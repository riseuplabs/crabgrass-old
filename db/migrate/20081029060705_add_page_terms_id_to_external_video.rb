class AddPageTermsIdToExternalVideo < ActiveRecord::Migration
  def self.up
    add_column :external_videos, :page_terms_id, :integer
    add_column :external_videos, :created_at, :datetime, :null => false
    add_column :external_videos, :updated_at, :datetime, :null => false
    ExternalVideo.all.each do |vid|
      vid.update_page_terms
      vid.created_at = vid.updated_at = Time.new
      vid.save
    end
  end

  def self.down
    remove_column :external_videos, :page_terms_id
    remove_column :external_videos, :created_at
    remove_column :external_videos, :updated_at
  end
end
