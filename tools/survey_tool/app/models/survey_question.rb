class SurveyQuestion < ActiveRecord::Base
  belongs_to :survey
  
  has_many :answers, :dependent => :destroy, :class_name => 'SurveyAnswer'
  acts_as_list :scope => :survey
end
