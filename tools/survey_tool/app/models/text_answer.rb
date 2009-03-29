class TextAnswer < SurveyAnswer
  def validate
    if self.regex.any? && !(self.value =~ Regexp.new(self.regex))
      errors.add(:value, "doesn't match /#{self.regex}/")
    end
  end
  def regex ; self.question.regex ; end
end
