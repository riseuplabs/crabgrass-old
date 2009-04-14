class SurveyToolToVersion3 < ActiveRecord::Migration
  def self.up
    Engines.plugins["survey_tool"].migrate(3)
  end

  def self.down
    Engines.plugins["survey_tool"].migrate(2)
  end
end
