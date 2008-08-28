module Gibberize::BaseHelper
  def flash_notice
    "<div class='errorExplanation'>#{flash[:notice]}</div>" if flash[:notice]
  end

  # this is set on RAILS_ROOT/config/sites.yml
  def site_default_language
    # the application controller sets @site in a before_filter
    Language.find_by_name(@site.default_language)
  end

  # Crabgrass UI is written in English
  def crabgrass_default_language
    Language.find_by_name("English")
  end

end

