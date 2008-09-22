class CreateGalleryShowings < ActiveRecord::Migration
  def self.up
    # even though this is a join table, we need a primary id
    # because that is what acts_as_list wants
    create_table "showings", :force => true do |t|
      t.references :asset
      t.references :gallery
      t.integer :position, :default => 0
    end
    
    add_index :showings, [:gallery_id, :asset_id], :name => :ga
    add_index :showings, [:asset_id, :gallery_id], :name => :ag
  end

  def self.down
    drop_table :showings
  end
end

