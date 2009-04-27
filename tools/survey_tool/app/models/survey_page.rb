class SurveyPage < Page

  def body_terms
    # uses SurveyQuestion.to_s()
    survey ? survey.questions.join("\n") : ""
  end
  
  def survey
    data
  end

  #def rating_enabled_for?(user)
  #  return false if !survey or !survey.rating_enabled
  #  user.may?(:admin,self) or (user.may?(:edit, self) and (survey.responses.find_by_user_id(user.id) ? survey.participants_can_rate? : true))
  #end

end

