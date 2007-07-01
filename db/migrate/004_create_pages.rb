class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.column :title, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :happens_at, :datetime
      t.column :resolved,   :boolean, :default => true
      t.column :public,     :boolean
      t.column :created_by_id,   :integer
      t.column :updated_by_id,   :integer
      t.column :summary,         :string
      t.column :type,            :string
      t.column :message_count, :integer, :default => 0

      # polymorphic association
      t.column :data_id, :integer
      t.column :data_type, :string
    end
  end

  def self.down
    drop_table :pages
  end
end
