require 'election'

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

  def result
    InstantRunoffResult.new(self)
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

class InstantRunoffResult < ElectionResult
  attr_reader :ranked_candidates

  def initialize(voteobj=nil)
    unless voteobj and voteobj.kind_of?( InstantRunoffVote )
      raise ArgumentError, "You must pass an InstantRunoffVote array.", caller
    end
    super(voteobj)

    votes = @election.votes.clone
    candidates = @election.candidates
    majority = votes.inject(0) {|n, value| n + value[1][0]}/2 + 1
    @ranked_candidates = Array.new()
    ranked_candidates = Array.new()

    loop do
      ranked_candidates = votes.sort do |a, b|
        b[1][0] <=> a[1][0]
      end.collect {|i| i[0]}
      @winners = ranked_candidates.find_all do |i|
        votes[i][0] >= majority
      end
      
      loser = ranked_candidates[-1]
      break if self.winner? or votes[loser][0] == votes[ranked_candidates[-2]][0]

      @ranked_candidates.unshift(loser)
      runoff(votes, loser) 
    end
    @ranked_candidates.unshift(*ranked_candidates)
  end

  def runoff(votes, loser)
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
