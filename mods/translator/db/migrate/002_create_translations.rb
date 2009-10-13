class CreateTranslations < ActiveRecord::Migration
  def self.up
    create_table :translations do |t|
      t.string :text
      t.integer :key_id, :language_id

      t.timestamps
    end
  end

  def self.down
    drop_table :translations
  end
end
