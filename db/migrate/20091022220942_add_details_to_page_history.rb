class AddDetailsToPageHistory < ActiveRecord::Migration
  def self.up
    add_column :page_histories, :details, :string
  end

  def self.down
    remove_column :page_histories, :details, :string
  end
end
