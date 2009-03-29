class SelectManyQuestion < SurveyQuestion
  def description
    :question_description_select_many.t
  end
  def partial ; 'surveys/select_many';  end
end
