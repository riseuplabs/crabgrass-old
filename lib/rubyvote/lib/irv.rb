class InstantRunoffVote < ElectionVote
  def initialize(votes=nil)
    @candidates = Array.new
    votes.each do |vote|
      @candidates = vote.uniq if vote.uniq.length > candidates.length
    end
    super(votes)
    @candidates.each do |candidate|
      @votes[candidate] = [0, Hash.new] unless @votes.has_key?(candidate)
    end
  end

  def result(params={})
    InstantRunoffResult.new(self, params)
  end
  
  protected
  def tally_vote(vote)
    votecopy = vote.dup
    candidate = votecopy.shift
    votes[candidate] = [0, Hash.new] unless votes.has_key?(candidate)
    votes[candidate][0] += 1
    if votes[candidate][1].has_key?(votecopy)
      votes[candidate][1][votecopy] += 1
    else
      votes[candidate][1][votecopy] = 1
    end
  end

  def verify_vote(vote=nil)
    vote.instance_of?( Array ) and
      vote == vote.uniq
  end
end

class InstantRunoffLogicVote < InstantRunoffVote
  def result(params={})
    InstantRunoffLogicResult.new(self, params)
  end
end

class InstantRunoffFirstRoundVote < InstantRunoffVote
  def result(params={})
    InstantRunoffFirstRoundResult.new(self, params)
  end
end

class InstantRunoffAllVote < InstantRunoffVote
  def result(params={})
    InstantRunoffAllResult.new(self, params)
  end
end

class InstantRunoffRandomVote < InstantRunoffVote
  def result(params={})
    InstantRunoffRandomResult.new(self, params)
  end
end

class InstantRunoffResult < ElectionResult
  attr_reader :ranked_candidates

  def initialize(voteobj=nil, params={})
    unless voteobj and voteobj.kind_of?( InstantRunoffVote )
      raise ArgumentError, "You must pass an InstantRunoffVote array.", caller
    end
    super(voteobj)

    votes = @election.votes.clone
    candidates = @election.candidates
    votes_sum = votes.inject(0) {|n, value| n + value[1][0]}
    @majority = votes_sum/2 + 1
    @ranked_candidates = Array.new()
    ranked_candidates = Array.new()
    losers = Array.new()

    if params.has_key?('candidate_count')
      apply_candidate_count(votes, params['candidate_count'])
    end
    if params.has_key?('vote_minimum')
      apply_vote_minimum(votes, params['vote_minimum'])
    end
    if params.has_key?('percent_minimum')
      apply_vote_minimum(votes, votes_sum * params['percent_minimum'])
    end
    if params.has_key?('percent_retention')
      apply_retention(votes, votes_sum * params['percent_retention'])
    end
    
    unless votes.length > 0
      @winners=[]
      return
    end

    begin
      ranked_candidates = votes.sort do |a, b|
        b[1][0] <=> a[1][0]
      end.collect {|i| i[0]}
      @winners = ranked_candidates.find_all do |i|
        votes[i][0] >= @majority
      end
    end while not self.winner? and next_round(votes, ranked_candidates)
    @ranked_candidates.unshift(*ranked_candidates)
  end

protected
  def apply_candidate_count(votes, candidate_count)
    if votes.size > candidate_count
      losers = votes.sort do |a, b|
        b[1][0] <=> a[1][0]
      end.collect {|i| i[0]}.last(votes.size - candidate_count)
      @ranked_candidates.unshift(losers) unless losers.empty?
      losers.each { |loser| remove_candidate(votes, loser) }
    end
  end

  def apply_vote_minimum(votes, vote_minimum)
    losers = votes.find_all do |i|
      i[1][0] < vote_minimum
    end.collect {|i| i[0]}
    if losers.length == votes.size
      votes.clear
    else
      @ranked_candidates.unshift(losers) unless losers.empty?
      losers.each { |loser| remove_candidate(votes, loser) }
    end
  end

  def apply_retention(votes, retention)
    losers = votes.sort do |a, b|
      b[1][0] <=> a[1][0]
    end.collect {|i| i[0]}
    partial_sum = 0
    while partial_sum < retention
      partial_sum += votes[losers.shift][0]
    end
    @ranked_candidates.unshift(losers) unless losers.empty?
    losers.each { |loser| remove_candidate(votes, loser) }
  end
  
  def next_round(votes, ranked_candidates)
    loser = ranked_candidates[-1]
    if votes.empty? or votes[loser][0] == votes[ranked_candidates[-2]][0]
      false
    else
      @ranked_candidates.unshift(loser)
      remove_candidate(votes, loser) 
      true
    end
  end

  def remove_candidate(votes, loser)
    votes.each_pair do |candidate, morevotes|
      hash = morevotes[1]
      hash.each_pair do |vote, count|
        hash.delete(vote)
        vote.delete(loser)
        hash[vote] = count
      end
    end
    votes[loser][1].each_pair do |vote, count|
      candidate = vote.shift
      votes[candidate][0] += count
      if votes[candidate][1].has_key?(vote)
        votes[candidate][1][vote] += count
      else
        votes[candidate][1][vote] = count
      end
    end
    votes.delete(loser)
  end
end

class InstantRunoffLogicResult < InstantRunoffResult
  def next_round(votes, ranked_candidates)
    losers = ranked_candidates.find_all do |i|
      votes[i][0] == votes[ranked_candidates[-1]][0]
    end
    if losers.inject(0) {|n, loser| n + votes[loser][0]} >= @majority
      false
    else
      @ranked_candidates.unshift(losers)
      losers.each do |loser|
        remove_candidate(votes, loser)
      end
      true
    end
  end
end

class InstantRunoffFirstRoundResult < InstantRunoffResult
  def next_round(votes, ranked_candidates)
    losers = ranked_candidates.find_all do |i|
      votes[i][0] == votes[ranked_candidates[-1]][0]
    end
    loser = losers.sort do |a, b|
      @election.votes[a][0] <=> @election.votes[b][0]
    end.last
    @ranked_candidates.unshift(loser)
    remove_candidate(votes, loser)
  end
end

class InstantRunoffAllResult < InstantRunoffResult
  def next_round(votes, ranked_candidates)
    losers = ranked_candidates.find_all do |i|
      votes[i][0] == votes[ranked_candidates[-1]][0]
    end
    if losers.length == ranked_candidates.length
      false
    else
      @ranked_candidates.unshift(losers)
      losers.each do |loser|
        remove_candidate(votes, loser)
      end
      true
    end
  end
end

class InstantRunoffRandomResult < InstantRunoffResult
  def next_round(votes, ranked_candidates)
    losers = ranked_candidates.find_all do |i|
      votes[i][0] == votes[ranked_candidates[-1]][0]
    end
    loser = losers[rand(losers.length)]
    @ranked_candidates.unshift(loser)
    remove_candidate(votes, loser)
  end
end
