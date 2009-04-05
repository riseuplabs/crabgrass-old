class SurveyResponse < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  has_many(:answers, :dependent => :destroy,
           :class_name => 'SurveyAnswer', :foreign_key => 'response_id')
  acts_as_rateable
end
