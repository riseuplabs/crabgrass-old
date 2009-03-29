class SurveyAnswer < ActiveRecord::Base
  belongs_to :question, :class_name => 'SurveyQuestion'
  belongs_to :response, :class_name => 'SurveyResponse'
  belongs_to :asset
end
