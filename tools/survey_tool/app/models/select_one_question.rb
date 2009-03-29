class SelectOneQuestion < SurveyQuestion
  def description
    :question_description_select_one.t
  end
  
  def partial ; 'surveys/select_one';  end
end
