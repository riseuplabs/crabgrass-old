class Tool::RateManyController < Tool::BaseController
  before_filter :fetch_poll
  
  def fetch_poll
    @poll = @page.data
  end
  
  def show
  end
  
  def new_possible
    return unless @poll
    @poll.possibles.create params[:possible]
    @poll.save
    redirect_to page_url(@page, :action => 'show')
  end
  
  def destroy_possible
    return unless @poll
    possible = Poll::Possible.find(params[:possible])
    possible.destroy
    redirect_to page_url(@page, :action => 'show')
  end
  
  def vote
    # destroy previous votes
    @poll.votes_by_user(current_user).each{|v| v.destroy}
  
    # create new votes
    new_votes = params['vote'] || []
    @poll.possibles.each do |possible|
      weight = new_votes[possible.id.to_s]
      possible.votes.create :user => current_user, :value => weight if weight
    end
    current_user.wrote(@page)
    redirect_to page_url(@page, :action => 'show')
  end

  # there has got to be a better way. Votes.delete_all?
  def clear_votes
    @poll.votes.clear
    redirect_to page_url(@page, :action => 'show')
  end
end
