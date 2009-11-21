class PollVote < ActiveRecord::Base

  set_table_name 'votes'

  belongs_to :possible
  belongs_to :user

  # this is necessary because of rails bug #323
  # https://rails.lighthouseapp.com/projects/8994/tickets/323-has_many-through-belongs_to_association-bug
  # TODO: rewrite this in rails2.3 which fixes the bug
  has_many :polls, :finder_sql =>
    'SELECT polls.* FROM polls ' +
    'JOIN possibles ON possibles.poll_id = polls.id ' +
    'WHERE possibles.id = #{possible_id}'
  def poll
    polls.first
  end

end
