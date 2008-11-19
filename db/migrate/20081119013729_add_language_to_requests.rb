class AddLanguageToRequests < ActiveRecord::Migration
  def self.up
    add_column :requests, :language, :string
  end

  def self.down
    remove_column :requests, :language
  end
end
