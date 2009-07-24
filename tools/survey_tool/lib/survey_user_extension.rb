module SurveyUserExtension
  def self.add_to_class_definition
    lambda {
      has_many :responses, :dependent => :destroy, :class_name => 'SurveyResponse'
    }
  end
  module InstanceMethods
    def response_for_survey(survey)
      @response ||= (survey.responses.find_by_user_id(self.id) || false)
    end
  end
end

