class AddRtlToLanguages < ActiveRecord::Migration
  def self.up
    add_column :languages, :rtl, :boolean, :default => false
  end

  def self.down
    remove_column :languages, :rtl
  end
end

