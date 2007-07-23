#!/usr/bin/ruby -I./lib

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

require 'election'
require 'condorcet'
require 'positional'
require 'runoff'

def print_winner(result)
  if not result.winner?
    puts "There is no winner."
  elsif result.winners.length == 1
    puts "The winner is %s" % result.winners[0]
  else
    puts "There is a tie between the following candidates: %s" % result.winners.join(", ")
  end
end

def condorcet_test1
  puts "USING CONDORCET..."
  puts "The winner should be: B" 

  vote_array = Array.new
  3.times {vote_array << "ABC".split("")}
  3.times {vote_array << "CBA".split("")}
  2.times {vote_array << "BAC".split("")}

  print_winner( PureCondorcetVote.new(vote_array).result )
end

def ssd_test1
  puts "USING CloneProofSSD..."
  puts "The winner should be: E" 

  vote_array = Array.new
  5.times {vote_array << "ACBED".split("")}
  5.times {vote_array << "ADECB".split("")}
  8.times {vote_array << "BEDAC".split("")}
  3.times {vote_array << "CABED".split("")}
  7.times {vote_array << "CAEBD".split("")}
  2.times {vote_array << "CBADE".split("")}
  7.times {vote_array << "DCEBA".split("")}
  8.times {vote_array << "EBADC".split("")}

  print_winner( CloneproofSSDVote.new(vote_array).result )
end

def ssd_test2
  puts "USING CloneProofSSD..."
  puts "The winner should be: D" 

  vote_array = Array.new
  5.times {vote_array << "ACBD".split("")}
  2.times {vote_array << "ACDB".split("")}
  3.times {vote_array << "ADCB".split("")}
  4.times {vote_array << "BACD".split("")}
  3.times {vote_array << "CBDA".split("")}
  3.times {vote_array << "CDBA".split("")}
  1.times {vote_array << "DACB".split("")}
  5.times {vote_array << "DBAC".split("")}
  4.times {vote_array << "DCBA".split("")}

  print_winner( CloneproofSSDVote.new(vote_array).result )
end

def ssd_test3
  puts "USING CloneProofSSD..."
  puts "The winner should be: B(?)" 

  vote_array = Array.new
  3.times {vote_array << "ABCD".split("")}
  2.times {vote_array << "DABC".split("")}
  2.times {vote_array << "DBCA".split("")}
  2.times {vote_array << "CBDA".split("")}

  print_winner( CloneproofSSDVote.new(vote_array).result )
end


def borda_test1
  puts "USING BORDA..."
  puts "The winner should be: B" 

  vote_array = Array.new
  3.times {vote_array << "ABC".split("")}
  3.times {vote_array << "CBA".split("")}
  2.times {vote_array << "BAC".split("")}

  print_winner( BordaVote.new(vote_array).result )
end

def plurality_test1
  puts "USING PLURALITY..."
  puts "The winner should be: C"

  vote_array = "ABCABCABCCCBBAAABABABCCCCCCCCCCCCCA".split("")

  print_winner( PluralityVote.new(vote_array).result )
end


def approval_test1
  puts "USING APPROVAL..."
  puts "The winner should be: A"

  vote_array = Array.new
  10.times {vote_array << "AB".split("")}
  10.times {vote_array << "CB".split("")}
  11.times {vote_array << "AC".split("")}
  5.times {vote_array << "A".split("")}

  print_winner( ApprovalVote.new(vote_array).result )
end

def runoff_test1
  puts "USING RUNOFF..."
  puts "The winner shold be: A"

  vote_array = Array.new
  142.times {vote_array << "ABCD".split("")}
  26.times {vote_array << "BCDA".split("")}
  15.times {vote_array << "CDBA".split("")}
  17.times {vote_array << "DCBA".split("")}

  print_winner( InstantRunoffVote.new(vote_array).result )
end

def runoff_test2
  puts "USING RUNOFF..."
  puts "The winner shold be: D"

  vote_array = Array.new
  42.times {vote_array << "ABCD".split("")}
  26.times {vote_array << "BCDA".split("")}
  15.times {vote_array << "CDBA".split("")}
  17.times {vote_array << "DCBA".split("")}

  print_winner( InstantRunoffVote.new(vote_array).result )
end

def runoff_test3
  puts "USING RUNOFF..."
  puts "The winner shold be: C"

  vote_array = Array.new
  42.times {vote_array << "ABCD".split("")}
  26.times {vote_array << "ACBD".split("")}
  15.times {vote_array << "BACD".split("")}
  32.times {vote_array << "BCAD".split("")}
  14.times {vote_array << "CABD".split("")}
  49.times {vote_array << "CBAD".split("")}
  17.times {vote_array << "ABDC".split("")}
  23.times {vote_array << "BADC".split("")}
  37.times {vote_array << "BCDA".split("")}
  11.times {vote_array << "CADB".split("")}
  16.times {vote_array << "CBDA".split("")}
  54.times {vote_array << "ADBC".split("")}
  36.times {vote_array << "BDCA".split("")}
  42.times {vote_array << "CDAB".split("")}
  13.times {vote_array << "CDBA".split("")}
  51.times {vote_array << "DABC".split("")}
  33.times {vote_array << "DBCA".split("")}
  39.times {vote_array << "DCAB".split("")}
  12.times {vote_array << "DCBA".split("")}

  print_winner( InstantRunoffVote.new(vote_array).result )
end

condorcet_test1()
ssd_test1()
ssd_test2()
ssd_test3()
borda_test1()
plurality_test1()
approval_test1()
runoff_test1()
runoff_test2()
runoff_test3()
