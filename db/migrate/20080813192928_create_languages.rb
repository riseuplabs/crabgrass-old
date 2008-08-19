class CreateLanguages < ActiveRecord::Migration
  def self.up
    create_table :languages do |t|
      t.string :name
      t.string :code
      t.timestamps
    end
    add_index(:languages, [:name,:code], { :name => 'languages_index', :unique => true })
    add_column :groups, :language, :string, :limit => 5
  end

  def self.down
    drop_table :languages
    remove_column :groups, :language
  end
end
