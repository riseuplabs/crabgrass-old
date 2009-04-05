class SurveyToolToVersion1 < ActiveRecord::Migration
  def self.up
    Engines.plugins["survey_tool"].migrate(1)
  end

  def self.down
    Engines.plugins["survey_tool"].migrate(0)
  end
end
