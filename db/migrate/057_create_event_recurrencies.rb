class CreateEventRecurrencies < ActiveRecord::Migration
  def self.up
    create_table :event_recurrencies, :force => true do |t|
      t.column :event_id, :integer
      t.column :start, :datetime
      t.column :end, :datetime
      t.column :type, :string # daily, weekly, monthly, yearly
      t.column :day_of_the_week, :string
      t.column :day_of_the_month, :string
      t.column :month_of_the_year, :string
      t.column :created_at, :datetime, :null => false
    end

  end

  def self.down
    drop_table :event_recurrencies
  end
end
