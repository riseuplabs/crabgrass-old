class AddRecipesForUser2 < ActiveRecord::Migration
  def self.up
    execute "INSERT INTO recipes (name, owner) VALUES ('Steak and Kidney Pie', 'user2')"
    execute "INSERT INTO recipes (name, owner) VALUES ('Shephards Pie', 'user2')"
    execute "INSERT INTO recipes (name, owner) VALUES ('Pot Pie', 'user2')"
  end

  def self.down
    execute "DELETE FROM recipes WHERE owner = 'user2'"
  end
end
