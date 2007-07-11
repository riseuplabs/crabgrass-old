class Poll::Vote < ActiveRecord::Base
  tz_time_attributes :created_at

  belongs_to :possible
  belongs_to :user
  has_many :polls, :finder_sql => 
    'SELECT polls.* FROM polls ' +
    'JOIN possibles ON possibles.poll_id = polls.id ' +
    'WHERE possibles.id = #{possible_id}'
  def poll
    polls.first
  end
  
end
