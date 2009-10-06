class ModerationToVersion5 < ActiveRecord::Migration
  def self.up
    Engines.plugins["moderation"].migrate(5)
  end

  def self.down
    Engines.plugins["moderation"].migrate(3)
  end
end
