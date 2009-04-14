class SurveyToolToVersion2 < ActiveRecord::Migration
  def self.up
    Engines.plugins["survey_tool"].migrate(2)
  end

  def self.down
    Engines.plugins["survey_tool"].migrate(0)
  end
end
