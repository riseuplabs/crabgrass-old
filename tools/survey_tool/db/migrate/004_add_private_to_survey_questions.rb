class AddPrivateToSurveyQuestions < ActiveRecord::Migration
  def self.up
    add_column :survey_questions, :private, :boolean, :default => false
  end

  def self.down
    remove_column :survey_questions, :private
  end
end
