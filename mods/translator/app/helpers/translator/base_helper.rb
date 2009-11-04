module Translator::BaseHelper
  def flash_notice
    "<div class='errorExplanation'>#{flash[:notice]}</div>" if flash[:notice]
  end

  def site_default_language
    Language.find_by_code(current_site.default_language)
  end

  # Crabgrass UI is written in English
  def crabgrass_default_language
    Language.find_by_code("en")
  end

  # just like link_to, but sets the <a> tag to have class 'active'
  # if last argument is true or if the url is in the form of a hash
  # and the current params match this hash.
  #
  # this is similar to the link_to_active in main crabgrass.
  # it would be nice if we could figure out a way to not repeat ourselves
  # here.
  def link_to_active(link_label, url_hash, active=nil)
    if url_hash.is_a? Hash and active.nil?
      url_hash[:controller] = "translator/" + url_hash[:controller]
      url_hash[:action] = 'index' if url_hash[:action].nil?
      selected = url_hash.inject(true) do |selected, p|
        param, value = p
        selected and params[param].to_s == value.to_s
      end
      selected_class = selected ? 'active' : ''
    else
      selected_class = active ? 'active' : ''
    end
    link_to(link_label,url_hash, :class => selected_class)
  end

end

