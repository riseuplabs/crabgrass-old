class Poll::Poll < ActiveRecord::Base
  has_many :pages, :as => :data
  def page; pages.first; end
    
  has_many :possibles, :dependent => :destroy, :class_name => 'Poll::Possible'
  def possible
    possibles.first || possibles.build
  end
  
  has_many :votes, :finder_sql => 
    'SELECT votes.* FROM votes ' +
    'JOIN possibles ON possibles.id = votes.possible_id ' +
    'WHERE possibles.poll_id = #{id}'

  def votes_by_user(user)
    Poll::Vote.find_by_sql ['SELECT votes.* FROM votes ' +
      'JOIN possibles ON possibles.id = votes.possible_id ' +
      'WHERE possibles.poll_id = ? AND votes.user_id = ?', id, user.id]
  end

  def delete_votes_by_user(user)
    Poll::Vote.connection.delete "DELETE FROM votes USING votes, possibles WHERE possibles.id = votes.possible_id AND possibles.poll_id = #{id} AND votes.user_id = #{user.id}"
  end
  
  def delete_votes_by_user_and_possible(user,possible)
  	Poll::Vote.connection.delete "DELETE FROM votes USING votes, possibles WHERE possibles.id = votes.possible_id AND possibles.id = #{possible.id} AND votes.user_id = #{user.id}"
  end
end
