class AddRecipesForUser1 < ActiveRecord::Migration
  def self.up
    execute "INSERT INTO recipes (name, owner) VALUES ('Lemon Meringue Pie', 'user1')"
    execute "INSERT INTO recipes (name, owner) VALUES ('Blueberry Pie', 'user1')"
    execute "INSERT INTO recipes (name, owner) VALUES ('Sugar Cream Pie', 'user1')"
  end

  def self.down
    execute "DELETE FROM recipes WHERE owner = 'user1'"
  end
end
