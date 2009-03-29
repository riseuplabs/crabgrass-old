class BooleanQuestion < SurveyQuestion
  def description
    :question_description_boolean.t
  end
  
  def partial ; 'surveys/boolean' ; end
end
