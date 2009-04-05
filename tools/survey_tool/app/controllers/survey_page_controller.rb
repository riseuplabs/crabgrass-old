require 'json'
class SurveyPageController < BasePageController
  stylesheet 'survey'
  javascript :extra

  def respond
    redirect_to(page_url(@page, :action => 'design')) unless @survey
    
    if request.post?
      save_response
    else
      edit_response
    end
  end

  def design
    @survey = Survey.new
  end

  def save_design
    @survey = Survey.new(params[:survey])
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

  protected

  # called early in filter chain
  def fetch_data
    return true unless @page
    @survey = @page.data
  end

  def edit_response
    @response = @survey.responses.build(:user_id => current_user)
  end

  def save_response
    require 'ruby-debug';debugger
    
    render :text => "Response Saved"
  end
end
