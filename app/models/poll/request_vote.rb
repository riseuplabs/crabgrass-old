class RequestVote < Vote
  REJECT = 0
  APPROVE = 1

  validates_format_of :votable_type, :with => /Request/
  validates_inclusion_of :value, :in => [REJECT, APPROVE], :message => "has to be 0 (reject) or 1 (approve)"
end