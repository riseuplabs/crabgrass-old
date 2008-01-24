class Poll::Vote < ActiveRecord::Base

  belongs_to :possible, :class_name => 'Poll::Possible', :foreign_key => 'possible_id'
  belongs_to :user
  has_many :polls, :finder_sql => 
    'SELECT polls.* FROM polls ' +
    'JOIN possibles ON possibles.poll_id = polls.id ' +
    'WHERE possibles.id = #{possible_id}'
  def poll
    polls.first
  end
  
end
