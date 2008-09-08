=begin
migrate our taggings table to be like the one needed by
acts_as_taggable_on
=end

class SwitchToActsAsTaggableOn < ActiveRecord::Migration
  def self.up
    add_column :taggings, :created_at, :datetime
    add_column :taggings, :context, :string
    add_column :taggings, :tagger_id, :integer
    add_column :taggings, :tagger_type, :string

    Tagging.connection.execute "UPDATE taggings SET context = 'tags'"

    remove_index "taggings", :name => "fk_taggings_taggable"

    add_index :taggings, :tag_id, :name => 'tag_id_index'
    add_index :taggings, [:taggable_id, :taggable_type, :context], :name => 'taggable_id_index'
  end

  def self.down
    remove_column :taggings, :created_at, :datetime
    remove_column :taggings, :context, :string
    remove_column :taggings, :tagger_id, :integer
    remove_column :taggings, :tagger_type, :string

    remove_index :taggings, 'tag_id_index'
    remove_index :taggings, 'taggable_id_index'

    add_index "taggings", ["taggable_type", "taggable_id"], :name => "fk_taggings_taggable"
  end
end

