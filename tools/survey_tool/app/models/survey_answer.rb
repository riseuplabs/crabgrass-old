class SurveyAnswer < ActiveRecord::Base
  CHOICE_FOR_UNCHECKED = "__UNCHECKED"

  attr_accessible :question_id, :asset_id, :value

  belongs_to :question, :class_name => 'SurveyQuestion'
  belongs_to :response, :class_name => 'SurveyResponse'
  belongs_to :asset

end

class VideoLinkAnswer < SurveyAnswer
  validate :supported

  def supported
    video = ExternalVideo.new(:media_embed => value)
    valid = video.valid?
    video.errors.each {|attr, msg| self.errors.add(:value, msg)}
    valid
  end
end