#
# join table for users and groups
#
class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.column :group_id,   :integer
      t.column :user_id,    :integer
    end
  end

  def self.down
    drop_table :memberships
  end
end
