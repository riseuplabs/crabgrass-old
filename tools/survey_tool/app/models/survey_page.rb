class SurveyPage < Page

  def body_terms
    # uses SurveyQuestion.to_s()
    survey ? survey.questions.join("\n") : ""
  end

  def survey
    data
  end

end

