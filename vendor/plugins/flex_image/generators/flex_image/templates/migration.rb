class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= table_name %> do |t|
      t.column :data, :binary, :size => 10_000_000, :null => false
      
      #Add other fields here
      #  t.column :name, :string
    end
    execute "ALTER TABLE `<%= table_name %>` MODIFY `data` MEDIUMBLOB"
  end

  def self.down
    drop_table :<%= table_name %>
  end
end
