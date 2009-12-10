class MakeProfileAccessFieldsDefaultToFalse < ActiveRecord::Migration
  def self.up
    [:foe, :friend, :peer, :fof, :stranger].each do |field|
      change_column :profiles, field, :boolean, :null => false, :default => false
      Profile.update_all("#{field} = 0", "#{field} is NULL")
    end
  end

  def self.down
    [:foe, :friend, :peer, :fof, :stranger].each do |field|
      change_column :profiles, field, :boolean
      Profile.update_all("#{field} = NULL", "#{field} = 0")
    end
  end
end
