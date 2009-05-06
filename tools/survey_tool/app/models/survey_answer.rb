#  create_table "survey_answers", :force => true do |t|
#    t.integer  "question_id",       :limit => 11
#    t.integer  "response_id",       :limit => 11
#    t.integer  "asset_id",          :limit => 11
#    t.text     "value"
#    t.string   "type"
#    t.datetime "created_at"
#    t.integer  "external_video_id", :limit => 11
#  end

class SurveyAnswer < ActiveRecord::Base
  CHOICE_FOR_UNCHECKED = "__UNCHECKED"

  attr_accessible :question_id, :asset_id, :value

  belongs_to :question, :class_name => 'SurveyQuestion'
  belongs_to :response, :class_name => 'SurveyResponse'
  belongs_to :asset

  def display_value
    value
  end
end


