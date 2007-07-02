class AddDetailsToMemberships < ActiveRecord::Migration
  def self.up
    add_column :memberships, :created_at, :datetime
    add_column :memberships, :page_id, :integer
    execute 'ALTER TABLE memberships ADD COLUMN id int(11) NOT NULL auto_increment, ADD PRIMARY KEY (id)'
  end

  def self.down
    #execute 'ALTER TABLE memberships DROP PRIMARY KEY'
    remove_column :memberships, :created_at
    remove_column :memberships, :page_id
    remove_column :memberships, :id
  end
end

