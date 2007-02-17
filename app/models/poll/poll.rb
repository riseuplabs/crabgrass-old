class Poll::Poll < ActiveRecord::Base
  
  has_many :possibles
  def possible
    possibles.first || possibles.build
  end
  
  has_many :votes, :finder_sql => 
    'SELECT votes.* FROM votes ' +
    'JOIN possibles ON possibles.id = votes.possible_id ' +
    'WHERE possibles.poll_id = #{id}'

  has_many :pages, :as => :tool
  def page
    pages.first
  end
end
