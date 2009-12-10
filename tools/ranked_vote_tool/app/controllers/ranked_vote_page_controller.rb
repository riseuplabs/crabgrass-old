class RankedVotePageController < BasePageController
  before_filter :fetch_poll
  before_filter :find_possibles, :only => [:show, :edit]
  stylesheet 'vote'
  permissions 'ranked_vote_page'
  javascript :extra, 'page'

  def show
    redirect_to(page_url(@page, :action => 'edit')) unless @poll.possibles.any?

    @who_voted_for = @poll.tally
    @sorted_possibles = @poll.ranked_candidates.collect { |id| @poll.possibles.find(id)}
  end

  def edit
  end

  # ajax or post
  def add_possible
    return if request.get?
    @possible = @poll.possibles.create params[:possible]
    if @poll.valid? and @possible.valid?
      @page.unresolve
      if request.xhr?
        render :template => 'ranked_vote_page/add_possible'
      else
        redirect_to page_url(@page)
      end
    else
      @poll.possibles.delete(@possible)
      flash_message_now :object => @possible unless @possible.valid?
      flash_message_now :object => @poll unless @poll.valid?
      if request.post?
        render :action => 'show'
      else
        render :text => 'error', :status => 500
      end
      return
    end
  end

  # ajax only, returns nothing
  # for this to work, there must be a <ul id='sort_list_xxx'> element
  # and it must be declared sortable like this:
  # <%= sortable_element 'sort_list_xxx', .... %>
  def sort
    if params[:sort_list_voted].empty?
      render :nothing => true
      return
    else
      @poll.votes.by_user(current_user).delete_all
      ids = params[:sort_list_voted]
      ids.each_with_index do |id, rank|
        next unless id.to_i != 0
        possible = @poll.possibles.find(id)
        @poll.votes.create! :user => current_user, :value => rank, :possible => possible
      end
      find_possibles
    end
  end

  def update_possible
    return unless request.xhr?
    @possible = @poll.possibles.find(params[:id])
    params[:possible].delete('name')
    @possible.update_attributes(params[:possible])
    render :template => 'ranked_vote_page/update_possible'
  end

  def edit_possible
    return unless request.xhr?
    @possible = @poll.possibles.find(params[:id])
    render :template => 'ranked_vote_page/edit_possible'
  end

  def destroy_possible
    possible = @poll.possibles.find(params[:id])
    possible.destroy
    render :nothing => true
  end

  def confirm
    # right now, this is just an illusion, but perhaps we should make the vote
    # only get saved after confirmation. people like the confirmation, rather
    # then the weird ajax-only sorting.
    redirect_to page_url(@page)
  end

  def print
    @who_voted_for = @poll.tally
    @sorted_possibles = @poll.ranked_candidates.collect { |id| @poll.possibles.find(id)}

    render :layout => "printer-friendly"
  end
  protected


  def fetch_poll
    @poll = @page.data if @page
    true
  end

  def find_possibles
    @possibles_voted = []
    @possibles_unvoted = []

    @poll.possibles.each do |pos|
      if pos.votes.by_user(current_user).first
        @possibles_voted << pos
      else
        @possibles_unvoted << pos
      end
    end

    @possibles_voted = @possibles_voted.sort_by { |pos| pos.votes.by_user(current_user).first.try.value || -1 }
  end

  def setup_view
    @show_print = true
  end

  def build_page_data
    RankingPoll.new
  end
end

