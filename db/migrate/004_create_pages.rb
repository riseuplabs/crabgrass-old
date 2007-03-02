class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.column :title, :string
	  t.column :created_at, :datetime
	  t.column :updated_at, :datetime
      t.column :happens_at, :datetime
	  t.column :resolved,   :boolean
	  t.column :public,     :boolean
	  t.column :needs_attention, :boolean
      t.column :created_by_id,   :integer
	  t.column :updated_by_id,   :integer
	  t.column :summary,         :string
	  t.column :type,            :string

	  # polymorphic association
	  t.column :tool_id, :integer
	  t.column :tool_type, :string
    end
  end

  def self.down
    drop_table :pages
  end
end
