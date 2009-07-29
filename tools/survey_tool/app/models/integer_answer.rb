class IntegerAnswer < SurveyAnswer

  def validate
    if(self.minimum.any? && self.minimum > self.value)
      errors.add(:value, "must be greater than #{self.minimum}")
    end
    if(self.maximum.any? && self.maximum < self.value)
      errors.add(:value, "must be smaller than #{self.maximum}")
    end
  end

  def self.minimum ; self.question.minimum ; end
  def self.maximum ; self.question.maximum ; end
  def value ; read_attribute(:value).to_i ; end
  def value=(v) write_attribute(:value, v.to_i) ; end
end
