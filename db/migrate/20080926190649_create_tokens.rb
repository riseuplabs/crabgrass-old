class CreateTokens < ActiveRecord::Migration
  def self.up
    create_table :tokens do |t|
      t.integer  :user_id,    :default => 0, :null => false
      t.string   :action,     :default => "", :null => false
      t.string   :value,      :limit => 40, :default => "", :null => false
      t.datetime :created_at, :null => false
    end
  end

  def self.down
    drop_table :tokens
  end
end
