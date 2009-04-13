module SurveyUserExtension
  def self.add_to_class_definition
    lambda { 
      has_many :responses, :dependent => :destroy, :class_name => 'SurveyResponse'
    }
  end
  module InstanceMethods
    def rating_for(rateable)
      rateable.ratings.by_user(self).first
    end
  
    def rated?(rateable)
      rating_for(rateable) ? true : false
    end 
  end
end

