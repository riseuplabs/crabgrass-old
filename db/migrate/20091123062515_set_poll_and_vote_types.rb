class SetPollAndVoteTypes < ActiveRecord::Migration

  def self.update_type_for_poll_votes(poll, type_name)
    poll.votes.each do |vote|
      vote.update_attribute('type', type_name)
    end
  end

  def self.update_type_for_ranking_poll
    RankedVotePage.all(:include => :data).each do |ranked_page|
      poll = ranked_page.data
      next if poll.nil?

      poll.update_attribute('type', 'RankingPoll')
      poll.reload
      update_type_for_poll_votes(poll, 'RankingVote')
    end
  end

  def self.update_type_for_rating_poll
    RateManyPage.all(:include => :data).each do |ranked_page|
      poll = ranked_page.data
      next if poll.nil?

      poll.update_attribute('type', 'RatingPoll')
      poll.reload
      update_type_for_poll_votes(poll, 'RatingVote')
    end
  end

  def self.up
    update_type_for_ranking_poll
    update_type_for_rating_poll
  end

  def self.down
    Poll.update_all('type = NULL')
  end
end
