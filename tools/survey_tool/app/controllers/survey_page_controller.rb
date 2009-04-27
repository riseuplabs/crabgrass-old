
class SurveyPageController < BasePageController
  stylesheet 'survey'
  javascript :extra
  javascript 'survey'
 
  include SurveyPagePermissionsHelper
  helper 'survey_page_permissions'

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
    @survey = @page.data || Survey.new
  end

  def edit
    if request.post?
      @survey.update_attributes!(params[:survey])
      current_user.updated(@page)
      flash_message :success => true
      redirect_to page_url(@page, :action => 'edit')
    end
  rescue
    @survey.errors.each {|e| flash_message :error => e.message }
  end

  protected

  # not called for 'show'
  def authorized?
    return true if @page.nil?
    @survey = @page.data || Survey.new

    if action?(:edit, :update)
      may_modify_survey?
    else
      false
    end
  end

  def setup_view
    @show_right_column = true
  end

end
