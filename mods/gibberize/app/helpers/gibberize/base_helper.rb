module Gibberize::BaseHelper
  def flash_notice
    "<div class='errorExplanation'>#{flash[:notice]}</div>" if flash[:notice]
  end

  # the application controller sets @site in a before_filter
  def default_language
    Language.find_by_name(@site.default_language)
  end
end

