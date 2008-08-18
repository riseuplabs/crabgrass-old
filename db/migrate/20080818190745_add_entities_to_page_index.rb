class AddEntitiesToPageIndex < ActiveRecord::Migration
  def self.up
    add_column :page_indices, :entities, :text

    # now update the page_index for each page
    Page.all.each { |page| page.update_index }
  end

  def self.down
    remove_column :page_indices, :entities
  end
end
