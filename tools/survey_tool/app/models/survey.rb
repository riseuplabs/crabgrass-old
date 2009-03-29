class Survey < ActiveRecord::Base
  has_many(:questions, :order => :position, :dependent => :destroy,
           :class_name => 'SurveyQuestion')
  has_many(:responses, :dependent => :destroy,
           :class_name => 'SurveyResponse')
end
