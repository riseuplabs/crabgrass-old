class CreateWikis < ActiveRecord::Migration
  def self.up
    create_table :wikis do |t|
	  t.column :body, :text
	  t.column :body_html, :text
	  t.column :updated_at, :datetime
	  t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :wikis
  end
end
