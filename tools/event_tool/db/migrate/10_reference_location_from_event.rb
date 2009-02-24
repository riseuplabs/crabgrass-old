class ReferenceLocationFromEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :location_id, :int

    Event.find(:all).each do |event|
      loc = Location.create! :city => event.city,
        :street => "#{event.address1}\n#{event.address2}",
        :state => event.state,
        :postal_code => event.postal_code,
        :geocode => "#{event.longitude}x#{event.latitude}",
        :country_name => event.country,
        :location_type => "auto_created"
      event.location_id = loc.id
      event.save
    end
    remove_column :events, :address1
    remove_column :events, :address2
    remove_column :events, :city
    remove_column :events, :state
    remove_column :events, :postal_code
    remove_column :events, :country
    remove_column :events, :directions
    remove_column :events, :latitude
    remove_column :events, :longitude
  end

  def self.down
    add_column :events, :address1, :string
    add_column :events, :address2, :string
    add_column :events, :city, :string
    add_column :events, :state, :string
    add_column :events, :postal_code, :string
    add_column :events, :country, :string
    add_column :events, :directions, :text
    add_column :events, :latitude, :float
    add_column :events, :longitude, :float
    remove_column :events, :location_id
  end
end
