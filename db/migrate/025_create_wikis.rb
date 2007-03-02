class CreateWikis < ActiveRecord::Migration
  def self.up
    create_table :wikis do |t|
	  t.add_column :body, :text
	  t.add_column :updated_at, :datetime
	  t.add_column :user_id, :integer
    end
  end

  def self.down
    drop_table :wikis
  end
end
