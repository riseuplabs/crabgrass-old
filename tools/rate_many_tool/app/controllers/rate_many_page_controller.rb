class RateManyPageController < BasePageController
  before_filter :fetch_poll
  javascript :extra, 'page'
  permissions 'rate_many_page'

  def show
    @possibles = @poll.possibles.sort_by{|p| p.position||0 }
  end

  # ajax or post
  def add_possible
    return if request.get?
    @possible = @poll.possibles.create params[:possible]
    if @poll.valid? and @possible.valid?
      @page.unresolve # update modified_at, auto_summary, and make page unresolved for other participants
      if request.xhr?
        render :template => 'rate_many_page/add_possible'
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

  def destroy_possible
    return unless @poll
    possible = @poll.possibles.find(params[:possible])
    possible.destroy

    current_user.updated @page # update modified date, and auto_summary, but do not make it unresolved

    redirect_to page_url(@page, :action => 'show')
  end

  def vote_one
    new_value = params[:value].to_i
    @possible = @poll.possibles.find(params[:id])
    @poll.votes.by_user(current_user).for_possible(@possible).delete_all
    @poll.votes.create! :user => current_user, :value => new_value, :possible => @possible
    current_user.updated(@page, :resolved => true)
  end

  def vote
    new_votes = params[:vote] || {}

    # destroy previous votes
    @poll.votes.by_user(current_user).delete_all

    # create new votes
    @poll.possibles.each do |possible|
      weight = new_votes[possible.id.to_s]
      @poll.votes.create! :user => current_user, :value => weight, :possible => possible if weight
    end
    current_user.updated(@page, :resolved => true)
    redirect_to page_url(@page, :action => 'show')
  end

  def clear_votes
    @poll.votes.clear
    redirect_to page_url(@page, :action => 'show')
  end

  # ajax only, returns nothing
  # for this to work, there must be a <ul id='sort_list_xxx'> element
  # and it must be declared sortable like this:
  # <%= sortable_element 'sort_list_xxx', .... %>
  def sort
    return unless params[:sort_list].any?
    ids = params[:sort_list]
    @poll.possibles.each do |possible|
      position = ids.index( possible.id.to_s )
      possible.update_attribute('position',position+1) if position
    end
    render :nothing => true
  end

  def print
  @possibles = @poll.possibles.sort_by{|p| p.position||0 }
    render :layout => "printer-friendly"
  end

  protected

  def fetch_poll
    return true unless @page
    @poll = @page.data
  end

  def setup_view
    @show_print = true
  end

  def build_page_data
    RatingPoll.new
  end
end
