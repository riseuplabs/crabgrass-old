class Tool::RequestController < Tool::BaseController
before_filter :fetch_poll

  def fetch_poll
    @poll = @page.data
  end
  
  def show
    
  end
  
  def new_possible
    return unless @poll
    possible = @poll.possibles.create params[:possible]
    redirect_to page_url(@page, :action => 'show')
  end
  
  def destroy_possible
    return unless @poll
    possible = Possible.find(params[:possible])
    possible.destroy
    redirect_to page_url(@page, :action => 'show')
  end
  
  def vote
    myvotes = params['vote'] || []
    votes = @poll.votes.find_by_user_id(current_user.id)
    votes.each{|v| v.destroy} if votes  
    
    if myvotes.length != 0
    @poll.possibles.each do |possible|
      weight = myvotes[possible.id.to_s]
      possible.votes.create :username => @user, :value => weight
    end
    end
    redirect_to page_url(@page, :action => 'show')
  end

  # there has got to be a better way. Votes.delete_all?
  def clear_votes
    @poll.votes.clear
    redirect_to page_url(@page, :action => 'show')
  end
end
