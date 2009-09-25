class ModerationToVersion3 < ActiveRecord::Migration
  def self.up
    Engines.plugins["moderation"].migrate(3)
  end

  def self.down
    Engines.plugins["moderation"].migrate(0)
  end
end
