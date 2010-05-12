class AssignPollsToVotes < ActiveRecord::Migration
  def self.up
    Possible.all.each do |possible|
      poll = possible.poll
      votes = possible.votes

      votes.each do |vote|
        vote.update_attributes({:votable_id => poll.id, :votable_type => 'Poll'})
      end
    end
  end

  def self.down
    Vote.update_all('votable_id = NULL')
    Vote.update_all('votable_type = NULL')
  end
end
