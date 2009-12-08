# a poll has several possiblities ('possibles')
# the user makes makes a vote for each possibility
# a vote can be a ranking (1st to 6th for a choice of 6 possibilities) for one of several possibilities
# or a vote can be a rating (0 to 5 for example) for every possibility
class Poll < ActiveRecord::Base
  has_many :pages, :as => :data
  def page; pages.first; end

  has_many :possibles, :dependent => :destroy
end
