class ModerationToVersion2 < ActiveRecord::Migration
  def self.up
    Engines.plugins["moderation"].migrate(2)
  end

  def self.down
    Engines.plugins["moderation"].migrate(0)
  end
end
