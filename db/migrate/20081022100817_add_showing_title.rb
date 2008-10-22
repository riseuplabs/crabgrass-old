class AddShowingTitle < ActiveRecord::Migration
  def self.up
    add_column :showings, :title, :string
  end

  def self.down
    remove_column :showings, :title
  end
end
