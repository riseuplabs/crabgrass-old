class RankingVote < Vote
  validates_numericality_of :value, :greater_than_or_equal_to => 0, :message => "has to be bigger than 0"
  validates_presence_of :possible, :on => :create, :message => "can't be blank"
end