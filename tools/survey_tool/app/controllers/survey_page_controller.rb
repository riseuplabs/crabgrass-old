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
      flash_message :success => 'Created a survey!'[:survey_created_message]
      redirect_to(page_url(@page, :action => 'respond'))
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

  def rate
    # set the rating for the current response
    if(params[:response] && params[:rating] && params[:rating].to_i != 0 &&
      resp = @survey.responses.find(params[:response]))
      if rating = current_user.rating_for(resp)
        # we must destroy the rating, so that the timestamp will change.
        rating.destroy
      end
      Rating.create!(:rateable => resp, :user => current_user, :rating => params[:rating])
    end

    @next = @survey.responses.unrated_by(current_user, 4)
    @next = @survey.responses.rated_by(current_user, 4) if @next.empty?
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
    if @page.nil?
      true
    elsif action?(:details, :show, :respond, :delete_response)
      current_user.may?(:edit, @page)
    elsif action?(:rate)
      @survey.rating_enabled? && current_user.may?(:edit, @page)
    else
      current_user.may?(:admin, @page)
    end
  end

  def save_response
    begin
      if @response.new_record?
        @response.save!
      else
        @response.update_attributes!(params[:response])
      end
    rescue Exception => exc
      # we have an error
      flash_message_now :object => @response
      return
    end

    # everything went well
    flash_message :success => 'Created a response!'[:response_created_message]
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
    @show_right_column = true
  end
end
