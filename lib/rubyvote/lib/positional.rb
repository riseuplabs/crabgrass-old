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
## ==== positional.rb ====
##
## This file contains positional election methods. Currently only
## includes an implementation of the Borda count election method.
#################################################################

##################################################################
## BordaVote and BordaResult Classes
##
## These classes inherit from and/or are modeled after the classes in
## election.rb and condorcet.rb

require 'election'

class BordaVote < ElectionVote

  def initialize(votes=nil)
    @candidates = Array.new
    votes.each do |vote|
      @candidates = vote.uniq if vote.uniq.length > candidates.length
    end
    super(votes)
  end

  def tally_vote(vote)
    points = candidates.length - 1
    vote.each do |candidate|
      @votes[candidate] = points
      points -= 1
    end
  end

  def verify_vote(vote=nil)
    vote.instance_of?( Array ) and
      vote == vote.uniq
  end

  def result
    BordaResult.new(self)
  end
end

class BordaResult < ElectionResult
  def initialize(voteobj=nil)
    super(voteobj)
    votes = @election.votes

    @ranked_candidates = votes.sort do |a, b|
      b[1] <=> a[1]
    end.collect {|i| i[0]}

    @winners = @ranked_candidates.find_all do |i|
      votes[i] == votes[@ranked_candidates[0]]
    end
  end

end
