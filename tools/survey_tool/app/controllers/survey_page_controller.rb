require 'json'
class SurveyPageController < BasePageController
  stylesheet 'survey'
  javascript :extra

  before_filter :fetch_response, :only => [:respond, :show]

  def respond
    if !@response.new_record? and !current_user.may?(:admin,@page)
      # don't show this page if we have the response already, unless we are
      # have admin access to this page.
      redirect_to page_url(@page, :action => 'show')
      return
    end

    if request.post? and @response.valid?
      @response.save!
      flash_message :success => 'Created a response!'[:response_created_message]
      redirect_to page_url(@page, :action => 'show')
    else
      flash_message_now :object => @response
    end
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
  end

  def show
    # if we don't have a saved response we can't view it
    redirect_to page_url(@page, :action => 'respond') if @response.new_record?
  end

  def rate
    if(params[:response] && params[:rating] && params[:rating].to_i != 0 &&
       resp = @survey.responses.find(params[:response]))
      if rating = current_user.rating_for(resp)
        rating.rating = params[:rating]
        rating.save!
      else
        Rating.create!(:rateable => resp, :user => current_user,
                       :rating => params[:rating])
      end
    end

    ids = JSON::load(params[:next]) rescue nil
    @resp = @survey.responses.find(ids.any? ? ids.shift : :first)
    @next = @survey.responses.next_rateables(current_user, ids)
    if current_user.rated?(@resp)
      @rating = current_user.rating_for(@resp).rating
      @survey_notice = "you previously rated this item with :rating"[:you_previousely_rated]%{ :rating => @rating }
      @next_link = true
    else
      @rating = 0
      @survey_notice = "Select a rating to see the next item"[:select_a_rating]
      @next_link = false
    end

    if request.xhr?
      render :update do |page|
        page.replace_html('response', :partial => 'response',
                          :locals => { :resp => @resp, :rating => @rating })
        page.replace_html('user_info', :partial => 'user_info',
                          :locals => { :resp => @resp })
        page.replace_html('next_responses', :partial => 'next_responses',
                          :locals => { :responses => @next })
        page.replace_html('current_rating', :partial => 'current_rating',
                          :locals => { :resp => @resp })
        page.replace_html('survey_notice', @survey_notice)
      end
    end
  end

  # show the details of a response. 
  def details
    if params[:jump]
      begin
        # what should the natural order be?
        index = @survey.response_ids.find_index(params[:id].to_i)
        if params[:jump] == 'next'
          id = @survey.response_ids[(index + 1) % @survey.response_ids.length] 
        elsif params[:jump] == 'prev'
          id = @survey.response_ids[index - 1]
        end
        redirect_to(page_url(@page, :action => 'details', :id => id))
      rescue
        redirect_to(page_url(@page, :action => 'list'))
      end
    else
      @response = @survey.responses.find_by_id(params[:id])
    end
  end

  protected

  # called early in filter chain
  def fetch_data
    return true unless @page
    @survey = @page.data
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

end
