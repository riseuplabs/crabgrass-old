module SurveyPagePermissionsHelper

  def may_create_survey_response?
    return false unless logged_in?

    @survey.responses_enabled? and current_user.may?(:edit, @page)
  end

  def may_modify_survey_response?(response=nil)
    return false unless logged_in?

    if response and response.user_id == current_user.id
      @survey.responses_enabled? # only edit while responses are still enabled.
    else
      current_user.may?(:admin, @page)
    end
  end

  # you should be able to view responses even if responses are disabled.
  def may_view_survey_response?(response=nil)
    return false unless logged_in?

    if response and response.user_id == current_user.id
      true
    elsif current_user.may?(:admin, @page)
      true
    elsif current_user.may?(:edit, @page)
      if current_user.response_for_survey(@survey)
        @survey.rating_enabled? and @survey.participants_can_rate?
      else
        false
      end
    else
      false
    end
  end

  def may_rate_survey_response?(response=nil)
    return false unless logged_in?

    if response and response.user_id == current_user.id
      false
    elsif !@survey or !@survey.rating_enabled?
      false
    elsif current_user.may?(:admin,@page)
      true
    elsif current_user.may?(:edit, @page)
      if current_user.response_for_survey(@survey)
        @survey.rating_enabled? and @survey.participants_can_rate?
      else
        false
      end
    else
      false
    end
  end

  def may_view_survey_response_ratings?(response=nil)
    return false unless logged_in?

    if response and response.user_id == current_user.id
      true
    elsif response and current_user.rated?(response)
      true
    elsif current_user.may?(:admin,@page)
      true
    else
      false
    end
  end

  def may_modify_survey?
    return false unless logged_in?
    current_user.may?(:admin, @page)    
  end

  def may_view_private_survey_questions?(response=nil)
    return false unless logged_in?
    
    if current_user.may?(:admin, @page)
      true
    elsif current_user.id == response.user_id
      true
    end
  end
  
end

