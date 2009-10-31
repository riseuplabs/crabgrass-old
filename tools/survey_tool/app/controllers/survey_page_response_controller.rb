##
## Handles the CRUD for survey responses
##

class SurveyPageResponseController < BasePageController
  stylesheet 'survey'
  javascript :extra
  javascript 'survey'
  helper 'survey_page'
  permissions 'survey_page'

  verify :method => :post, :only => [:make, :update, :destroy]

  def new
    @response = SurveyResponse.new
  end

  # this should be 'create', but that is currently used by BasePageController.
  # grrr. that breaks our nice CRUD.
  def make
    @response = @survey.responses.create!(params[:response]) do |resp|
      resp.user = current_user # (user_id is protected)
    end
    current_user.updated(@page)
    flash_message :success => I18n.t(:survey_thanks_submit_message)
    if may_rate_survey_response?
      flash_message :success => I18n.t(:survey_please_check_and_rate_message)
    else
      flash_message :success => I18n.t(:survey_please_check_message)
    end
    redirect_to page_url(@page, :action => 'response-show', :id => @response.id)
  rescue Exception => exc
    flash_message_now :exception => exc, :object => @response
    render :template => 'survey_page_response/new'
  end

  def edit
  end

  def update
    @response.update_attributes!(params[:response])
    flash_message :success => I18n.t(:survey_thanks_submit_message)
    if may_rate_survey_response?
      flash_message :success => I18n.t(:survey_please_check_and_rate_message)
    else
      flash_message :success => I18n.t(:survey_please_check_message)
    end
    redirect_to page_url(@page, :action => 'response-show', :id => @response.id)
  rescue Exception => exc
    flash_message_now :object => @response, :exc => exc
  end

  def destroy
    @response.destroy
    if @response.user_id == current_user.id and may_create_survey_response?
      redirect_to page_url(@page, :action => 'response-new')
    elsif may_view_survey_response?
      redirect_to page_url(@page, :action => 'response-list')
    else
      redirect_to page_url(@page, :action => 'show')
    end
  end

  def show
    @response = @survey.responses.find_by_id params[:id]
    if params[:jump]
      redirect_to page_url(@page, :action => 'response-show', :id => get_jump_id)
    end
  end

  def list
    @responses = @survey.responses.paginate(:all,
      :include => ['answers', 'ratings'],
      :page => params[:page])
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
    if( params[:id] && params[:rating] && @response)
      if rating = current_user.rating_for(@response)
        # we must destroy the rating, so that the timestamp will change.
        rating.destroy
      end
      # don't count zero rating, but create the record so we know the user
      # didn't want to rate it:
      params[:rating] = nil if params[:rating] == "0"
      Rating.create!(:rateable => @response, :user => current_user, :rating => params[:rating])
    end

    # display the current response
    @previous_response = @response
    @next = next_four_responses(@survey)
    @response = @next.shift # pop off the first item
    if current_user.rated?(@response)
      @rating = current_user.rating_for(@response).rating
    else
      @rating = 0
    end
  end


  protected

  # called early in filter chain
  def fetch_data
    return true unless @page
    @survey = @page.data || Survey.new
    @response = @survey.responses.find_by_id(params[:id]) if params[:id]
  end

  def setup_view
    @show_right_column = true unless action?(:rate)
    @show_posts = action?(:list)
  end

  def next_four_responses(survey)
    responses = survey.responses.unrated_by(current_user, 4)
    if responses.size < 4
      responses += survey.responses.rated_by(current_user, 4-responses.size)
    end
    return responses
  end

  # gets the next or previous response id in the list.
  def get_jump_id
    index = @survey.response_ids.find_index(params[:id].to_i)
    if params[:jump] == 'next'
      return @survey.response_ids[(index+1) % @survey.response_ids.size]
    elsif params[:jump] == 'prev'
      return @survey.response_ids[index-1]
    end
  end
end

