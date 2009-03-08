class SuperAdminToVersion1 < ActiveRecord::Migration
  def self.up
    Engines.plugins["super_admin"].migrate(1)
  end

  def self.down
    Engines.plugins["super_admin"].migrate(0)
  end
end
