class Poll::Poll < ActiveRecord::Base
  has_many :pages, :as => :data
  def page; pages.first; end
    
  has_many :possibles
  def possible
    possibles.first || possibles.build
  end
  
  has_many :votes, :dependent => :delete_all, :finder_sql => 
    'SELECT votes.* FROM votes ' +
    'JOIN possibles ON possibles.id = votes.possible_id ' +
    'WHERE possibles.poll_id = #{id}'

  def votes_by_user(user)
    Poll::Vote.find_by_sql ['SELECT votes.* FROM votes ' +
      'JOIN possibles ON possibles.id = votes.possible_id ' +
      'WHERE possibles.poll_id = ? AND votes.user_id = ?', id, user.id]
  end

end
