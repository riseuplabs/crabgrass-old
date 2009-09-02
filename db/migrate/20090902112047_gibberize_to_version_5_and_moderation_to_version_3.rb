class GibberizeToVersion5AndModerationToVersion3 < ActiveRecord::Migration
  def self.up
    Engines.plugins["gibberize"].migrate(5)
    Engines.plugins["moderation"].migrate(3)
  end

  def self.down
    Engines.plugins["gibberize"].migrate(0)
    Engines.plugins["moderation"].migrate(0)
  end
end
