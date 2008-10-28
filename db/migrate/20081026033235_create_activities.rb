class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.integer :subject_id
      t.string  :subject_type
      t.string  :subject_name
      t.integer :object_id
      t.string  :object_type
      t.string  :object_name
      t.string  :type
      t.string  :extra
      t.integer :key
      t.boolean :public, :default => false
      t.datetime :created_at
    end
    # note: the name suffixes with digits are specifying the key length to schema.rb
    execute "CREATE INDEX subject_0_4_0 ON activities (subject_id, subject_type(4), public)"
    add_index :activities, :created_at, :name => 'created_at'
  end

  def self.down
    drop_table :activities
  end
end

