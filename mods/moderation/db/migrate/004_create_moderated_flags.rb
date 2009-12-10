class CreateModeratedFlags < ActiveRecord::Migration

  def self.up
    create_table :moderated_flags do |t|
      t.column :type, 	:string, :null => false
      t.column :vetted_at,	:datetime
      t.column :vetted_by_id,	:integer
      t.column :deleted_at,	:datetime
      t.column :deleted_by_id,	:integer
      t.column :reason_flagged,	:string
      t.column :comment,	:string
      t.column :created_at,	:datetime
      t.column :updated_at,	:datetime
      t.column :user_id,	:integer
      t.column :foreign_id,	:integer, :null => false
    end
  end

  def self.down
    drop_table :moderated_flags  
  end

end
