class CreateLanguages < ActiveRecord::Migration
  def self.up
    create_table :languages do |t|
      t.string :name
      t.string :code
      t.timestamps
    end

    add_index(:languages, [:name,:code], { :name => 'languages_index', :unique => true })

    add_column :groups, :language_id, :integer

    remove_column :users, :language
    add_column :users, :language_id, :integer

    # i'm going to remove a column, i gotta redo a index it is part of
    # i have to execute SQL manually because rails migrations don't get the index name right
    execute "ALTER TABLE `profiles` DROP INDEX `profiles_index`"
    remove_column :profiles, :language
    add_index "profiles", ["entity_id", "entity_type", "stranger", "peer", "friend", "foe"], :name => "profiles_index"
    add_column :profiles, :language_id, :integer
  end

  def self.down
    drop_table :languages

    remove_column :users, :language_id
    add_column :users, :language, :string, :limit => 5

    remove_column :groups, :language_id

    execute "ALTER TABLE `profiles` DROP INDEX `profiles_index`"
    add_column :profiles, :language, :string,  :limit => 5
    add_index "profiles", ["entity_id", "entity_type", "language", "stranger", "peer", "friend", "foe"], :name => "profiles_index"
    remove_column :profiles, :language_id
  end
end
