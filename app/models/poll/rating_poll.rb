class RatingPoll < Poll
  has_many :votes, :foreign_key => :votable_id, :class_name => "RatingVote", :dependent => :delete_all
end