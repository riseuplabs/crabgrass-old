class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.column :name,           :string
      t.column :summary,        :string
      t.column :url,            :string
      t.column :type,           :string
      t.column :parent_id,      :integer
      t.column :admin_group_id, :integer
      t.column :council,        :boolean
      t.column :created_on,     :timestamp
      t.column :updated_at,     :timestamp
      t.column :picture_id,     :integer
    end
  end

  def self.down
    drop_table :groups
  end
end
