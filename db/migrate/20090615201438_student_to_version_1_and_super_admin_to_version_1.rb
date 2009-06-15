class StudentToVersion1AndSuperAdminToVersion1 < ActiveRecord::Migration
  def self.up
    Engines.plugins["student"].migrate(1)
    Engines.plugins["super_admin"].migrate(1)
  end

  def self.down
    Engines.plugins["student"].migrate(0)
    Engines.plugins["super_admin"].migrate(0)
  end
end
