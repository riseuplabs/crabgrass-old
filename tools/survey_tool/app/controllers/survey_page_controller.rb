class SurveyPageController < BasePageController
  stylesheet 'survey'
  javascript :extra

  def show
    redirect_to(page_url(@page, :action => 'design')) unless @survey
  end

  def design
    @survey = Survey.new
  end

  def save_design
    @survey = Survey.new(params[:survey])
    if @survey.save
      @page.data = @survey
      flash_message :success => 'Created a survey!'[:survey_created_message]
      redirect_to(page_url(@page, :action => 'show'))
    else
      @survey.errors.each {|e| flash_message :error => e.message }
      redirect_to(page_url(@page, :action => 'design'))
    end
  end

  # called early in filter chain
  def fetch_data
    return true unless @page
    @survey = @page.data
  end
end