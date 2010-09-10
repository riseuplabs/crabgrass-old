class SetFullCouncilPowersTrueForCouncils < ActiveRecord::Migration
  def self.up
    Council.update_all("full_council_powers = true")
  end

  def self.down
  end
end
