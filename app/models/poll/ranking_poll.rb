class RankingPoll < Poll
  has_many :votes, :foreign_key => :votable_id, :class_name => "RankingVote", :dependent => :delete_all

  # TODO: uncomment in rails2.3
  # delegate :winners, :rank, ... :to => :results
  def ranked_candidates
    @results.ranked_candidates
  end

  def winners
    @results.winners
  end

  def rank(possible)
    @results.rank(possible)
  end

  # returns:
  # a hash mapping possible name to an array of users who picked ranked this highest
  # sets @borda_vote
  def tally
    who_voted_for = {}  # what users picked this possible as their first
    hash = {}           # tmp hash
    ballots = []        # returned array of arrays for BordaVote

    ## first, build hash of votes
    ## the key is the user's id and the element is an array of all their votes
    ## where each vote is [possible_name, vote_value].
    ## eg. { 5 => [["A",0],["B",1]], 22 => [["A",1],["B",0]]
    possibles = self.possibles.find(:all, :include => {:votes => :user})

    possibles.each do |possible|
      possible.votes.each do |vote|
        hash[vote.user.name] ||= []
        hash[vote.user.name] << [possible.id, vote.value]
      end
    end

    ## second, build ballots.
    ## each element is an array of a user's
    ## votes, sorted in order of their preference
    ## eg. [ ["A", "B"],  ["B", "A"], ["B", "A"] ]
    hash.each_pair do |user_id, votes|
      sorted_by_value = votes.sort_by{|vote|vote[1]}
      top_choice_name = sorted_by_value.first[0]
      ballots << sorted_by_value.collect{|vote|vote[0]}
      who_voted_for[top_choice_name] ||= []
      who_voted_for[top_choice_name] << user_id
    end

    ballots << [] if ballots.blank?
    @results = BordaVote.new(ballots)

    return who_voted_for
  end
end