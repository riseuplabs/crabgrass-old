module Gibberize::BaseHelper
  def flash_notice
    "<div class='errorExplanation'>#{flash[:notice]}</div>" if flash[:notice]
  end

  # the base controller set @site in a before_filter
  # let's use it in case in the future thare's more sites than just 'default'
  def default_language
    Language.find_by_name(@site.default_language)
  end
end

