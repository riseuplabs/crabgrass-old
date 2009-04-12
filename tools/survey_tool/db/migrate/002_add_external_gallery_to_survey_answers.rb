class AddExternalGalleryToSurveyAnswers < ActiveRecord::Migration
  def self.up
    add_column :survey_answers, :external_gallery_id, :integer
  end
  
  def self.down
    remove_column :survey_answers, :external_gallery_id
  end
end
