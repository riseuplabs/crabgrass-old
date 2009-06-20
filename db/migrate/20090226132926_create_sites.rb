class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.string  :name
      t.string  :domain
      t.string  :email_sender
      t.integer :pagination_size
      t.integer :super_admin_group_id
      t.text    :translators
      t.string  :translation_group
      t.string  :default_language
      t.text    :available_page_types
      t.text    :evil
      t.boolean :tracking
      t.boolean :default, :default => false
    end
  end

  def self.down
    drop_table :sites
  end
end
