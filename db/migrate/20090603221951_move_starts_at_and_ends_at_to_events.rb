class MoveStartsAtAndEndsAtToEvents < ActiveRecord::Migration
  def self.up
    remove_column :pages, :starts_at
    remove_column :pages, :ends_at

    remove_column :page_terms, :starts_at
    remove_column :page_terms, :ends_at

    add_column :pages, :happens_at, :datetime
    add_column :events, :starts_at, :datetime
    add_column :events, :ends_at,  :datetime

    add_index "events", ["starts_at"], :name => "index_events_on_starts_at"
    add_index "events", ["ends_at"], :name => "index_events_on_ends_at"
  end

  def self.down
    add_column :pages, :starts_at, :datetime
    add_column :pages, :ends_at, :datetime

    add_column :page_terms, :starts_at, :datetime
    add_column :page_terms, :ends_at, :datetime

    add_index "pages", ["starts_at"], :name => "index_pages_on_starts_at"
    add_index "pages", ["ends_at"], :name => "index_pages_on_ends_at"


    remove_column :pages, :happens_at
    remove_column :events, :starts_at
    remove_column :events, :ends_at
  end
end
