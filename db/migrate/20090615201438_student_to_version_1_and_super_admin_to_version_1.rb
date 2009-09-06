class StudentToVersion1AndSuperAdminToVersion1 < ActiveRecord::Migration
  def self.up
    Engines.plugins["student"].migrate(1)
    Engines.plugins["moderation"].migrate(1)
  end

  def self.down
    Engines.plugins["student"].migrate(0)
    Engines.plugins["moderation"].migrate(0)
  end
end
