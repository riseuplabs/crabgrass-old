class AddStartAtEndAtToPages < ActiveRecord::Migration
def self.up
  add_column :pages, :starts_at, :datetime
  add_column :pages, :ends_at, :datetime
  remove_column :pages, :happens_at
  remove_column :events, :time_start
  remove_column :events, :time_end
end

def self.down		
  remove_column :pages, :starts_at
  remove_column :pages, :ends_at
  add_column :pages, :happens_at, :datetime
  add_column :events, :time_start, :datetime
  add_column :events, :time_end,  :datetime
end

end
