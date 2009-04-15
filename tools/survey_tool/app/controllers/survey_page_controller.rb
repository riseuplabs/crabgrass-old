require 'json'
class SurveyPageController < BasePageController
  stylesheet 'survey'
  javascript :extra

  before_filter :fetch_response, :only => [:respond, :show]
  
  def respond
    if request.post?
      save_response
    else
      @response.valid?
      flash_message_now :object => @response
    end
  end
  
  def delete_response
    redirect_to page_url(@page) unless request.post?
    if params[:id] && current_user.may?(:admin, @page)
      @response = @survey.responses.find(params[:id])
    else
      @response = @survey.responses.find_by_user_id(current_user.id)
    end
    if @response
      if params[:jump]
        begin
          index = @survey.response_ids.find_index(params[:id].to_i)
          id = @survey.response_ids[(params[:jump] == 'prev') ? (index-1) : 
                                    ((index+1) % @survey.response_ids.size)]
        end
      end
      @response.destroy
    end
    redirect_to page_url(*[@page, (params[:jump] && @response ? {
                                     :action => 'details', :id => id } : nil)
                            ].compact)
  end

  def design
    @survey ||= Survey.new
  end

  def save_design
    if @survey
      @survey.update_attributes(params[:survey])
    else
      @survey = Survey.new(params[:survey])
    end
    if @survey.save
      @page.data = @survey
      flash_message :success => 'Saved Your Changes!'[:survey_updated_message]
      redirect_to(page_url(@page, :action => 'design'))
    else
      @survey.errors.each {|e| flash_message :error => e.message }
      redirect_to(page_url(@page, :action => 'design'))
    end
  end

  def list
    @responses = @survey.responses.paginate(:all, :include => ['answers', 'ratings'], :page => params[:page])
  end

  def show
    # if we don't have a saved response we can't view it
    redirect_to page_url(@page, :action => 'respond') if @response.new_record?
  end

  # xhr and get
  # The user may either rate the current response, or skip it. The response
  # has either been rated already or not. If it has been rated already, it may
  # have been given a rating of nil, to let us know that the user has skipped it.
  #
  # There is a slight problem, which I am not sure how to solve. If the user skips
  # a response by choosing not to rate it, we cannot put it at the end of the 
  # 'unrated' queue because this makes it impossible to skip the last unrated
  # response. However, if we put the skipped item at the bottom of the rated
  # queue, it makes it so you won't see it for a long time. 
  #
  # This is how it works now, which I guess is better. Skip, then, means that you
  # really don't want to have to rate it.
  #
  def rate
    # set the rating for the current response
    if( params[:response] && params[:rating] &&
        resp = @survey.responses.find(params[:response])
    )
      if rating = current_user.rating_for(resp)
        # we must destroy the rating, so that the timestamp will change.
        rating.destroy
      end
      # don't count zero rating, but create the record so we know the user
      # didn't want to rate it:
      params[:rating] = nil if params[:rating] == "0" 
      Rating.create!(:rateable => resp, :user => current_user, :rating => params[:rating])
    end

    # display the current response
    @next = next_four_responses(@survey)
    @response = @next.shift # pop off the first item
    if current_user.rated?(@response)
      @rating = current_user.rating_for(@response).rating
      @survey_notice = "You previously rated this item with {rating}."[:you_previousely_rated, {:rating => @rating.to_s}]
      @next_link = true
    else
      @rating = 0
      @survey_notice = "Select a rating to see the next item."[:select_a_rating]
      @next_link = false
    end
  end

  def details
    if params[:jump]
      begin
        index = @survey.response_ids.find_index(params[:id].to_i)
        id = @survey.response_ids[(index+1) % @survey.response_ids.size] if params[:jump] == 'next'
        id = @survey.response_ids[index-1] if params[:jump] == 'prev'
        redirect_to page_url(@page, :action => 'details', :id => id)
        return
      end
    end
    @response = @survey.responses.find_by_id(params[:id])
  end

  protected
  
  def authorized?
    return true if @page.nil?
    if action?(:details, :show, :delete_response)
      current_user.may?(:edit, @page)
    elsif action?(:rate)
      @page.rating_enabled_for?(current_user)
    elsif action?(:respond)
      @survey.responses_enabled? && current_user.may?(:edit, @page)
    else
      current_user.may?(:admin, @page)
    end
  end
  

  def save_response
    begin
      if @response.new_record?
        created = true
        @response.save!
      else
        @response.update_attributes!(params[:response])
      end
    rescue Exception => exc
      # we have an error
      flash_message_now :object => @response, :exc => exc
      return
    end

    # everything went well
    if created
      flash_message :success => 'Created a response!'[:response_created_message]
    else
      flash_message :success => 'Updated your response'[:response_updated_message]
    end
    redirect_to page_url(@page, :action => 'show')
  end

  # called early in filter chain
  def fetch_data
    return true unless @page
    @survey = @page.data || Survey.new
  end

  def fetch_response
    redirect_to(page_url(@page, :action => 'design')) and return unless @survey

    # try to find an existing response
    @response = @survey.responses.find_by_user_id(current_user) if logged_in?

    if @response.nil?
      # build a new response
      @response = @survey.responses.build(params[:response])
      @response.user = current_user
    end
  end

  def setup_view
    @show_right_column = true unless action?(:rate)
  end

  def next_four_responses(survey)
    responses = survey.responses.unrated_by(current_user, 4)
    if responses.size < 4
      responses += survey.responses.rated_by(current_user, 4-responses.size) 
    end
    return responses
  end

end
