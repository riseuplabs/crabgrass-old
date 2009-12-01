
class BordaVote
  attr_reader :winners
  attr_reader :ranked_candidates

  def initialize(ballots)
    @ballots = ballots
    tally_votes
  end

  def tally_votes
    # ballots: [["a", "b", "c"], ["a", "c", "b"]]

    # {"a" => 4, "b" => 1, "c" => 1}
    candidate_votes = {}

    # the number of items on the longest ballot - 1
    first_place_points = @ballots.sort_by(&:length).last.length - 1

    @ballots.each do |ballot|
      # ballot:  ["c", "a", "b"]
      points = first_place_points
      ballot.each do |candidate|
        # candidate: "a"
        candidate_votes[candidate] ||= 0
        candidate_votes[candidate] += points
        points -= 1
      end
    end

    @ranked_candidates = candidate_votes.sort do |cv1, cv2|
      cv2[1] <=> cv1[1]
    end.collect(&:first)

    # {4 => ["a"], 1 => ["b", "c"]}
    votes_to_candidates = {}

    candidate_votes.each do |candidate, votes_count|
      votes_to_candidates[votes_count] ||= []
      votes_to_candidates[votes_count] << candidate
    end


    winners_votes = votes_to_candidates.keys.sort.last
    @winners = votes_to_candidates[winners_votes] || []

     # { "c" => 1, "a" => 2, "b" => 2}
    @ranks = {}

    # keys are vote counts sorted from highest to lowest
    # [4, 1]
    votes_to_candidates.keys.sort.reverse.each_with_index do |votes, rank|
      candidates = votes_to_candidates[votes]
      candidates.each do |candidate|
        # counting from 0
        @ranks[candidate] = rank + 1
      end
    end
  end

  def rank(possibility)
    @ranks[possibility]
  end

end