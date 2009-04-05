class Survey < ActiveRecord::Base
  has_many(:questions, :order => :position, :dependent => :destroy,
           :class_name => 'SurveyQuestion')
  has_many(:responses, :dependent => :destroy,
           :class_name => 'SurveyResponse')

  def new_questions_attributes=(question_attributes)
    self.questions = []
    question_attributes.each do |attribute|
      self.questions << attribute["type"].constantize.create(attribute)
    end
  end
end
