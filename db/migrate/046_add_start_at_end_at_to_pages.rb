class AddStartAtEndAtToPages < ActiveRecord::Migration
def self.up
  add_column :pages, :starts_at, :datetime
  add_column :pages, :ends_at, :datetime
  remove_column :pages, :happens_at
end

def self.down		
  remove_column :pages, :starts_at
  remove_column :pages, :ends_at
  add_column :pages, happens_at, :datetime
end

end
