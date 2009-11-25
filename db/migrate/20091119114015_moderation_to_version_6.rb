class ModerationToVersion6 < ActiveRecord::Migration
  def self.up
    Engines.plugins["moderation"].migrate(6)
  end

  def self.down
    Engines.plugins["moderation"].migrate(5)
  end
end
