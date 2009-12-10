class CreateRelationships < ActiveRecord::Migration
  def self.up
    rename_table :contacts, :relationships
    add_column :relationships, :type, :string, :limit => 10
    add_column :relationships, :discussion_id, :integer
    execute 'ALTER TABLE relationships ADD COLUMN id int(11) NOT NULL auto_increment, ADD PRIMARY KEY (id)'

    # all pre-existing relationships are friendships
    User.connection.execute("UPDATE relationships SET type = 'Friendship'")
  end

  def self.down
    remove_column :relationships, :type
    remove_column :relationships, :discussion_id
    remove_column :relationships, :id
    rename_table :relationships, :contacts
  end
end
