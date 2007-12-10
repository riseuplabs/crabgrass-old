# Range voting as described in wikipedia.
# (http://en.wikipedia.org/wiki/Range_voting)

class RangeVote < ElectionVote
  def initialize(votes = nil, range = 1..10)
    @valid_range = range
    super(votes)
  end

  def result
    RangeResult.new(self)
  end

  protected
  def verify_vote(vote=nil)
    vote.instance_of?(Hash) && vote.all?{|c,score| @valid_range.include?(score)}
  end

  def tally_vote(vote)
    vote.each do |candidate, score|
      if @votes.has_key?(candidate)
        @votes[candidate] += score
      else
        @votes[candidate] = score
        @candidates << candidate
      end
    end
  end
end

class RangeResult < PluralityResult
end
