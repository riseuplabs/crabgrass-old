class CreatePageViews < ActiveRecord::Migration
  def self.up
    create_table :page_views, :options => 'ENGINE=MyISAM' do |t|
      t.integer :page_id, :null => false
    end
    connection = ActiveRecord::Base.connection
    add_column :page_terms, :views, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :page_terms, :views
    drop_table :page_views
  end
end
