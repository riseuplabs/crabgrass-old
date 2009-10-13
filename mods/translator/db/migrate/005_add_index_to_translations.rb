class AddIndexToTranslations < ActiveRecord::Migration
  def self.up
    add_index :translations, :key_id
  end

  def self.down
    remove_index :translations, :key_id
  end
end

