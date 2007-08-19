class CreateEvents < ActiveRecord::Migration
	def self.up
		create_table :events do |t|
			t.column :description,	:text
			t.column :description_html,	:text
			t.column :time_start,	:datetime
			t.column :time_end,	:datetime
			t.column :is_all_day, :boolean, :default => false
			t.column :is_cancelled, :boolean, :default => false
			t.column :is_tentative, :boolean, :default => true
			t.column :location,	:string
			# repeat event
		end
	end

	def self.down		
		drop_table :events
	end

end
