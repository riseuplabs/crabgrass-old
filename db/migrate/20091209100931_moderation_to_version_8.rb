class ModerationToVersion8 < ActiveRecord::Migration
  def self.up
    Engines.plugins["moderation"].migrate(8)
  end

  def self.down
    Engines.plugins["moderation"].migrate(7)
  end
end
