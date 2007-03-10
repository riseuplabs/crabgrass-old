class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.column :name,           :string
      t.column :full_name,      :string
      t.column :summary,        :string
      t.column :url,            :string
      t.column :type,           :string
      t.column :parent_id,      :integer
      t.column :admin_group_id, :integer
      t.column :council,        :boolean
      t.column :created_at,     :datetime
      t.column :updated_at,     :datetime
      t.column :avatar_id,      :integer
    end
  end

  def self.down
    drop_table :groups
  end
end
