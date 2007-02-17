class CreatePossibles < ActiveRecord::Migration
  def self.up
    create_table :possibles do |t|
      t.column :name, :string
      t.column :action, :text
      t.column :poll_id, :integer
    end
  end

  def self.down
    drop_table :possibles
  end
end
