class CreateWikiLocks < ActiveRecord::Migration
  def self.up
    create_table :wiki_locks do |t|
      t.integer :wiki_id
      t.text :locks
      t.integer :lock_version, :default => 0
    end
  end

  def self.down
    drop_table :wiki_locks
  end
end
