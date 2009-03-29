module SurveyUserExtension
  def self.add_to_class_definition
    lambda { 
      has_many :responses, :dependent => :destroy
    }
  end
end
