module SurveyPagePermission
  #    :admin_may_rate
  #
  #    :edit_may_create, :edit_may_see_responses,
  #    :edit_may_rate,   :edit_may_see_ratings,
  #
  #    :view_may_create, :view_may_see_responses,
  #    :view_may_rate,   :view_may_see_ratings
  #
  # Survey
  #  def authorized?
  #    return true if @page.nil?
  #    @survey = @page.data || Survey.new
  #    This is done in fetch_data now.
  #
  #    if action?(:edit, :update)
  #      may_update_survey?
  #    elsif action?(:show)
  #      current_user.may?(:view,@page)
  #    else
  #      current_user.may?(:admin,@page)
  #    end
  #  end

  def may_show_survey?
    @page.nil? or
    current_user.may?(:view,@page)
  end

  def may_update_survey?
    @page.nil? or
    logged_in? && current_user.may?(:admin, @page)
  end

  alias_method :may_edit_survey?, :may_update_survey?

  # SurveyPageResponse
  #  def authorized?
  #    return true if @page.nil?
  #    @response = @survey.responses.find_by_id(params[:id]) if params[:id]
  #
  #    if action?(:new, :make)
  #      may_create_survey_response?
  #    elsif action?(:update, :edit)
  #      may_modify_survey_response?(@response)
  #    elsif action?(:destroy, :edit)  # the :edit is caught above already...
  #      may_destroy_survey_response?(@response)
  #    elsif action?(:show)
  #      may_view_survey_response?(@response)
  #    elsif action?(:list)
  #      may_view_survey_response?
  #    elsif action?(:rate)
  #      may_rate_survey_response?(@response)
  #    else
  #      current_user.may?(:admin,@page)
  #    end
  #  end
  #

  def may_create_survey_response?
    return false unless logged_in?

    if current_user.may?(:admin,@page)
      true
    elsif current_user.may?(:edit,@page)
      @survey.edit_may_create?
    elsif current_user.may?(:view,@page)
      @survey.view_may_create?
    end
  end

  %w[new make].each {|action|
    alias_method "may_#{action}_survey_page_response?".to_sym, :may_create_survey_response?
  }

  def may_modify_survey_response?(response=nil)
    return false unless logged_in?

    if response and response.user_id == current_user.id
      may_create_survey_response?  # only edit while responses are still enabled.
    else
      current_user.may?(:admin, @page)
    end
  end

  %w[update edit].each {|action|
    alias_method "may_#{action}_survey_page_response?".to_sym, :may_modify_survey_response?
  }

  def may_destroy_survey_response?(response=@response)
    return false unless logged_in?

    if response and response.user_id == current_user.id
      true
    else
      current_user.may?(:admin, @page)
    end
  end

  alias_method :may_destroy_survey_page_response?, :may_destroy_survey_response?

  # you should be able to view responses even if responses are disabled.
  def may_view_survey_response?(response=@response)
    return false unless logged_in?

    if response and response.user_id == current_user.id
      true # you can always see your own
    elsif current_user.may?(:admin, @page)
      true
    elsif current_user.may?(:edit, @page)
      @survey.edit_may_see_responses?
    elsif current_user.may?(:view, @page)
      @survey.view_may_see_responses?
    else
      false
    end
  end

  %w[show list].each {|action|
    alias_method "may_#{action}_survey_page_response?".to_sym, :may_view_survey_response?
  }

  def may_rate_survey_response?(response=nil)
    return false unless logged_in?

    if response and response.user_id == current_user.id
      false # you can never rate your own
    elsif current_user.may?(:admin,@page)
      @survey.admin_may_rate?
    elsif current_user.may?(:edit,@page)
      @survey.edit_may_rate?
    elsif current_user.may?(:view,@page)
      @survey.view_may_rate?
    else
      false
    end
  end

  def may_view_survey_response_ratings?(response=nil)
    return false unless logged_in?

    if current_user.may?(:admin,@page)
      true
    elsif current_user.may?(:edit,@page)
      @survey.edit_may_see_ratings?
    elsif current_user.may?(:view,@page)
      @survey.view_may_see_ratings?
    else
      false
    end
  end

  # we assume that may_view_survey_response has already been
  # called and returned true.
  def may_view_survey_question?(response, question)
    return false unless logged_in?

    if question.private?
      if current_user.may?(:admin, @page)
        true
      elsif current_user.id == response.user_id
        true
      else
        false
      end
    else
      true
    end
  end

end

