#
# join table for users and groups
#
class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.column :group_id,   :integer
      t.column :user_id,    :integer
      t.column :page_id,    :integer
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :memberships
  end
end
