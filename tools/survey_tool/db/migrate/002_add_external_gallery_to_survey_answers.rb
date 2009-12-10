class AddExternalGalleryToSurveyAnswers < ActiveRecord::Migration
  def self.up
    add_column :survey_answers, :external_video_id, :integer
  end

  def self.down
    remove_column :survey_answers, :external_video_id
  end
end
