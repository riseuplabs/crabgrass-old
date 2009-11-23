class RatingPoll < Poll
  has_many :votes, :as => :votable, :class_name => "RatingVote"
end