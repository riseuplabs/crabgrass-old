RubyVote: Election Methods Library in Ruby
=============================================

.. Caution::

   This software is pre release software. The authors of this software
   are neither expert Ruby programmers or elections in election
   methods. We are hackers and enthusiasts in both. This software has
   bugs and it's quite possible that is has bugs that may skew
   results. If you understand Ruby or election methods, please audit
   the code.

Overview
---------

**Latest Version:** 0.2

**Download Latest Version:** `here
<http://rubyforge.org/projects/rubyvote>`__

`RubyVote` is an election methods library implemented in Ruby.  It is
designed to make it very easy to implement a variety of different types
of elections in Ruby including relatively complex election methods like
Condorcet.  It could be useful for any sort of election, poll, or
decision making.

New Versions
*************

`RubyVote` is graciously hosted by `RubyForge
<http://rubyforge.org/>`__.

You can visit the `RubyVote` homepage (a version of this file) here:

 http://rubyvote.rubyforge.org/

You can visit the RubyForge project page to download the latest
version of software, get access to the latest development version from
Subversion, to file or bug, to look through documentation, to
participate in the forums, or to contribute in other ways. That page
is here:

 http://rubyforge.org/projects/rubyvote


More Information
*****************

`RubyVote` is a library -- not an application or a voting machine. It
simply takes the raw "tallies" of votes and computes the results.
Currently, it does not include any sample interfaces (although if
contributed, these may be included).

`RubyVote` current includes a set of classes to tally votes and compute
winners in elections or votes using a series of different methods.
Currently these include:

* `Plurality`__ or "winner-take-all"
* `Approval`__
* `Borda`__
* `Simple Condorcet`__
* `Condorcet with Cloneproof SSD`__
* `Instant Runnoff Voting`__ (Thanks Alexis Darrasse!)

__ http://en.wikipedia.org/wiki/Plurality_electoral_system
__ http://en.wikipedia.org/wiki/Approval_voting
__ http://en.wikipedia.org/wiki/Borda_count
__ http://en.wikipedia.org/wiki/Condorcet_method
__ http://en.wikipedia.org/wiki/Schulze_method
__ http://en.wikipedia.org/wiki/Instant_Runoff_Voting

Writing support for a currently unsupported voting method is a fantastic
way to to contribute to this module.

How To Use This Library
-------------------------

Using this library is relatively simple but will differ per election
methods. In each case, you will need to ``require`` the appropriate
file for the type of election you will be running and then create a
new vote object. You should then either pass an array of votes to the
object upon creation or pass votes in one at at a time.


.. Note::

   *You* are responsible for ensuring that the votes are in correct
   form before you hand them to this module. This will not currently
   check for most types of invalid votes and does not (currently)
   accept a list of candidates at creation from which it checks all
   votes. As such, new candidates will be created when seen. If you
   think this is a meaningful addition to this library, please send a
   patch. Otherwise, please check for the validity of votes BEFORE you
   pass them to this election module.

Examples of each type of election currently supported can be seen in
the test.rb file distributed in this archive.

ElectionVote Objects
*********************

Each ElectionVote object has the following exposed attributions:

* ElectionVote#votes -- returns a list of votes that have been tallied
* ElectionVote#candidates -- returns a list of candidates

Additionally, each subclass will create a #results method which will
return an ElectionResult subclass of the appropriate type.

Currently, you use this module by creating any of the following types
of vote objects:

Plurality
^^^^^^^^^^

This is the most simple "winner-take-all" system. The array passed to
the new vote object should be an array of strings. Each string is
counted as one vote for a candidate.

Example::

 require 'election'
 vote_array = [ "A", "B", "B", "A" ]
 resultobject = PluralityVote.new(vote_array).result

Approval
^^^^^^^^^

Approval is similar to plurality voting except that users can vote for
more than one candidate at once naming all of the candidates that they
approve of.

Example::

 require 'election'
 vote_array = [ ["A", "B"],  ["B", "A"], ["B"] ]
 resultobject = ApprovalVote.new(vote_array).result

Borda
^^^^^^

Borda is a positional voting system and, as a result, takes a list of
ranked candidates and assigns points to each candidates based on their
order. In Borda, there are *n* candidate and the first candidates is
assigned *n* - 1 points and each subsequent candidate is assigned one
less point. The candidate is assigned no points.

Currently, all candidates should be ranked in each ballot.

Example::

 require 'positional'
 vote_array = [ ["A", "B"],  ["B", "A"], ["B", "A"] ]
 resultobject = BordaVote.new(vote_array).result

Pure Condorcet
^^^^^^^^^^^^^^^^

Condorcet is a preferential system and, as such, each vote must list
of ranked preferences from most to least preferred. Currently, all
candidates must be listed. No ties are allowed on ballots with the
current implementation.

Example::

 require 'condorcet'
 vote_array = [ ["A", "B"],  ["B", "A"], ["B", "A"] ]
 resultobject = PureCondorcetVote.new(vote_array).result

Cloneproof Schwartz Sequential Dropping
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

`Cloneproof SSD` is a Condorcet variant with the ability to create
winners in circular defeats (e.g., A beats B, B beats C, C beats A)
where this is no clear winner in Condorcet. It is used identically to
Pure Condorcet.

Example::

 require 'condorcet'
 vote_array = [ ["A", "B"],  ["B", "A"], ["B", "A"] ]
 resultobject = CloneproofSSDVote.new(vote_array).result

Instant Runnoff Voting (IRV)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

IRV is a preferential voting system used widely for government elections
in Australia and New Zealand and elsewhere. IRV asks voters to rank
candidates in preference and then holds a series of "runoff" elections
by eliminating the weakest candidate and recomputing the election
results until there exists a candidate who has a majority of the
remaining votes.

Example::

 require 'runoff'
 vote_array = [ ["A", "B"],  ["B", "A"], ["B", "A"] ]
 resultobject = InstantRunoffVote.new(vote_array).result


ElectionResult Objects
***********************

Each election result object will have the following methods:

* #winner? -- return Boolean as to the winner or winners of an election
* #winners -- an array of winners of the election
* #ranked_candidates -- (where available) a list of ranked candidates


License
--------

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
02110-1301, USA.

Look in the COPYING file for the text of the GNU GPL.

Authors
--------

Currently, the only contributor to this program is Benjamin Mako Hill
working at the MIT Media Lab. Please feel free to contribute to this
module and get your name added here.

For more information about Mako and his programs, you can see his
homepage here:

 http://mako.cc

For more information about the MIT Media Lab, you can see its homepage
here:

 http://www.media.mit.edu

