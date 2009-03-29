class BooleanAnswer < SurveyAnswer
  def value ; read_attribute(:value) == 'true' ; end
  def value=(v) write_attribute(:value, (v == 'true')) ; end
end
