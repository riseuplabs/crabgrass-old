class CreateRecipesTable < ActiveRecord::Migration
  def self.up
    create_table :recipes do |t|
      t.column :name, :string
      t.column :owner, :string
    end
  end

  def self.down
    drop_table :recipes
  end
end
