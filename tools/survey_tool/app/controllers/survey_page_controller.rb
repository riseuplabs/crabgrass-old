
class SurveyPageController < BasePageController
  stylesheet 'survey'
  javascript :extra
  javascript 'survey'

  permissions 'survey_page'

#  def new
#    @survey = Survey.new
#  end
#
#  def make
#    @survey = Survey.create! params[:survey]
#    @page.data = @survey
#    @page.save
#  rescue Exception => exc
#    flash_message_now :object => @survey, :exception => exc
#  end

  def show
    if @page.data.nil?
      redirect_to page_url(@page, :action => 'edit')
    else
      @survey.responses(true)
      # ^^ there is no good reason why this is necessary, but it seems to be the case.
    end
  end

  def edit
    if request.post?
      if @survey.new_record?
        @survey = Survey.create!(params[:survey])
        @page.data = @survey
        @page.save!
      else
        @survey.update_attributes!(params[:survey])
      end
      current_user.updated(@page)
      flash_message :success => true
      redirect_to page_url(@page, :action => 'edit')
    end
  rescue
    @survey.errors.each {|e| flash_message :error => e.message }
  end

  protected

  def fetch_data
    @survey=@page.data || Survey.new
  end

  def setup_view
    @show_right_column = true
  end

end
