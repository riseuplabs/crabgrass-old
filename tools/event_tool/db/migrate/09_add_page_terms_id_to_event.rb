class AddPageTermsIdToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :page_terms_id, :integer
    add_column :events, :created_at, :datetime, :null => false
    add_column :events, :updated_at, :datetime, :null => false
    Event.all.each do |event|
      event.update_page_terms
      event.created_at = event.updated_at = Time.new
      event.save
    end
  end

  def self.down
    remove_column :events, :page_terms_id
    remove_column :events, :created_at
    remove_column :events, :updated_at
  end
end
