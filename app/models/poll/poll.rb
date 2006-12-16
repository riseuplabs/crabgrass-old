module Poll
  class Poll < ActiveRecord::Base
    has_many :possibles
    #has_many :votes, :through => :possibles, :join => 'xxxx'

    has_many :pages, :as => :tool
    def page
	  pages.first
	end
  end
end
