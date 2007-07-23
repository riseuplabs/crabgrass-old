# election library -- a ruby library for elections
# copyright © 2005 MIT Media Lab and Benjamin Mako Hill

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.

#################################################################
## ==== election.rb ====
##
## This file contains the core ElectionVote and ElectionResults
## classes and the most common and simple election methods including
## plurality and approval voting.
#################################################################

##################################################################
## ElectionVote Classes and SubClasses
##
## There classes are used to store, verify, and "tally" (i.e. count
## votes for the standard Election superclass and for the most common
## types of elections.

class ElectionVote
  attr_reader :votes
  attr_reader :candidates

  def initialize(votes=nil)
    @votes = Hash.new unless defined?(@votes)
    @candidates = Array.new unless defined?(@candidates)

    if votes
      if votes.instance_of?( Array )
        votes.each do |vote|
          self.tally_vote(vote) if self.verify_vote(vote)
        end
      else
        raise ElectionError, "Votes must be in the form of an array.", caller
      end
    end
  end

  protected
  # by default, this is set to look if the vote is defined. it should
  # be overridden in each class
  def verify_vote(vote=nil)
    vote ? true : false
  end

  # by default, this does nothing. it must be redefined in any subclass
  def tally_vote
    self.verify_vote(vote)
  end
end

class PluralityVote < ElectionVote
  def result
    PluralityResult.new(self)
  end
  
  protected
  def verify_vote(vote=nil)
    vote.instance_of?( String )
  end

  def tally_vote(candidate)
    if @votes.has_key?(candidate)
      @votes[candidate] += 1
    else
      @votes[candidate] = 1
      @candidates << candidate
    end
  end
end

class ApprovalVote < PluralityVote
  def result
    ApprovalResult.new(self)
  end

  protected
  def verify_vote(vote=nil)
    vote.instance_of?( Array ) and vote.length >= 1
  end

  def tally_vote(approvals)
    approvals.each {|candidate| super(candidate)}
  end
end


##################################################################
## Election Result Classes
##

## There classes are used to compute and report the results of an
## election. In almost all cases, these will be returned by the
## #results method of a corresponding ElectionVote subclass.

class ElectionResult
  attr_reader :winners

  def initialize(voteobj=nil)
    unless voteobj and voteobj.kind_of?( ElectionVote )
      raise ArgumentError, "You must pass a ElectionVote array.", caller
    end

    @election = voteobj
    @winners = Array.new
  end

  def winner
    @winners[0] if @winners.length > 0
  end

  def winner?
    @winners.length > 0
  end

end

class PluralityResult < ElectionResult
  attr_reader :ranked_candidates

  def initialize(voteobj=nil)
    super(voteobj)

    votes = @election.votes
    candidates = @election.candidates
    
    @ranked_candidates = votes.sort do |a, b|
      b[1] <=> a[1]
    end.collect {|a| a[0]}
    
    # winners are anyone who has the same number of votes as the
    # first person
    @winners = @ranked_candidates.find_all do |i|
      votes[i] == votes[@ranked_candidates[0]]
    end
  end
end

# this class is complete because results for approval are computed
# identically to results from plurality
class ApprovalResult < PluralityResult
end
  
class ElectionError < ArgumentError
end

