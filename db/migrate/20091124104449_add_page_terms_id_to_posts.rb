class AddPageTermsIdToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :page_terms_id, :integer
  end

  def self.down
    remove_column :posts, :page_terms_id
  end
end
