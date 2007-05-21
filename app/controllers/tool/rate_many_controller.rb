class Tool::RateManyController < Tool::BaseController
  before_filter :fetch_poll
    
  def show
  end
  
  def new_possible
    return unless @poll
    possible = @poll.possibles.create params[:possible]
    if @poll.save
      @page.unresolve
      redirect_to page_url(@page, :action => 'show')
    else
      @poll.possibles.delete(possible)
      message :object => possible
      render :action => 'show'
    end
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
    new_votes = params['vote'] || {} 
    @poll.possibles.each do |possible|
      weight = new_votes[possible.id.to_s]
      possible.votes.create :user => current_user, :value => weight if weight
    end
    current_user.updated(@page, :resolved => true)
    redirect_to page_url(@page, :action => 'show')
  end

  def clear_votes
    @poll.votes.clear
    redirect_to page_url(@page, :action => 'show')
  end
  
  protected
  
  def fetch_poll
    return true unless @page
    @poll = @page.data
  end

end
