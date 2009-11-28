class ModerationToVersion7 < ActiveRecord::Migration
  def self.up
    Engines.plugins["moderation"].migrate(7)
  end

  def self.down
    Engines.plugins["moderation"].migrate(6)
  end
end
