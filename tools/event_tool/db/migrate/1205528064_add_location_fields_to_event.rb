class AddLocationFieldsToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :address1, :string
    add_column :events, :address2, :string
    add_column :events, :city, :string
    add_column :events, :state, :string
    add_column :events, :postal_code, :string
    add_column :events, :country, :string
    add_column :events, :directions, :text
  end

  def self.down
    remove_column :events, :address1
    remove_column :events, :address2
    remove_column :events, :city
    remove_column :events, :state
    remove_column :events, :postal_code
    remove_column :events, :country
    remove_column :events, :directions
  end
end
