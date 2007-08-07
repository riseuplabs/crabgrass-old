
$: << "#{RAILS_ROOT}/lib/rubyvote/lib"
require 'condorcet'

class Tool::RankedVoteController < Tool::BaseController

  stylesheet 'vote'
      
  def show
    redirect_to(page_url(@page, :action => 'edit')) unless @poll.possibles.any?

    array_of_votes, @who_voted_for = build_vote_arrays    
    @result = CloneproofSSDVote.new( array_of_votes ).result
    @possibles = @poll.possibles.sort_by do |possible|
      @result.rank_of_candidate(possible.name) || 10000
    end
    @winners = @possibles.select{|p| @result.winners.include? p.name}
  end

  def edit
    @possibles = @poll.possibles.sort_by do |pos|
      default_for_unvoted = @poll.possibles.size + rand(@poll.possibles.size)
      pos.value_by_user(current_user, default_for_unvoted)
    end
  end
    
  # ajax or post
  def add_possible
    return if request.get?
    @possible = @poll.possibles.create params[:possible]
    if @poll.valid? and @possible.valid?
      @page.unresolve
      redirect_to page_url(@page) unless request.xhr?
    else
      @poll.possibles.delete(@possible)
      message :object => @possible unless @possible.valid?
      message :object => @poll unless @poll.valid?
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
    sort_list_key = params.keys.grep(/^sort_list/)
    return unless sort_list_key.any?
    
    @poll.delete_votes_by_user(current_user)
    ids = params[sort_list_key[0]]
    @poll.possibles.each do |possible|
      rank = ids.index( possible.id.to_s )
      possible.votes.create :user => current_user, :value => rank if rank
    end
    render :nothing => true
  end
  
  def update_possible
    return unless request.xhr?
    @possible = @poll.possibles.find(params[:id])
    params[:possible].delete('name')
    @possible.update_attributes(params[:possible])
  end
    
  def edit_possible
    return unless request.xhr?
    @possible = @poll.possibles.find(params[:id])
  end

  def destroy_possible    
    possible = @poll.possibles.find(params[:id])
    possible.destroy
    render :nothing => true
  end
  
  protected

  # returns:
  # 1) an array suitable for RubyVote
  # 2) a hash mapping possible name to an array of users who picked ranked this highest

  def build_vote_arrays
    who_voted_for = {}  # what users picked this possible as their first
    hash = {}           # tmp hash
    array_of_votes = [] # returned array for rubyvote
    
    ## first, build hash of votes
    ## the key is the user's id and the element is an array of all their votes
    ## where each vote is [possible_name, vote_value].
    ## eg. { 5 => [["A",0],["B",1]], 22 => [["A",1],["B",0]]
    possibles = @poll.possibles.find(:all, :include => {:votes => :user})  
    # (perhaps this should be changed if we start caching User.find(id)
    #possibles = @poll.possibles.find(:all, :include => :votes)
    
    possibles.each do |possible|
      possible.votes.each do |vote|
        hash[vote.user.name] ||= []
        hash[vote.user.name] << [possible.name, vote.value]
      end  
    end
       
    ## second, build array_of_votes.
    ## each element is an array of a user's
    ## votes, sorted in order of their preference
    ## eg. [ ["A", "B"],  ["B", "A"], ["B", "A"] ]
    hash.each_pair do |user_id, votes|
      sorted_by_value = votes.sort_by{|vote|vote[1]}
      top_choice_name = sorted_by_value.first[0]
      array_of_votes << sorted_by_value.collect{|vote|vote[0]}
      who_voted_for[top_choice_name] ||= []
      who_voted_for[top_choice_name] << user_id
    end

    return array_of_votes, who_voted_for
  end
  
  def authorized?
    return super unless @page
    current_user.may?(:admin, @page)
  end  
  
  before_filter :fetch_poll
  def fetch_poll
    @poll = @page.data if @page
    true
  end

end
