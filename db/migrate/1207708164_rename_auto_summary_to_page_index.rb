class RenameAutoSummaryToPageIndex < ActiveRecord::Migration
  def self.up
    create_table :page_indices do |t|
      t.column "page_id",            :integer
      t.column "body",               :text
      t.column "delta",              :boolean
      t.column "class_display_name", :string
      t.column "tags",               :string
    end
  end

  def self.down
    drop_table :page_indices
  end
end
