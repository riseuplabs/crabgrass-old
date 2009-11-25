class RatingVote < Vote
  validates_numericality_of :value, :only_integer => true, :message => "can only be whole number."
  validates_inclusion_of :value, :in => -2..2, :message => "can only be between -2 and 2."

  validates_presence_of :possible, :on => :create, :message => "can't be blank"
end