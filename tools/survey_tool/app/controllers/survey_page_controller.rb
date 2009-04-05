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