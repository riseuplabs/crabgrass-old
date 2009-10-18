module Translator::TranslationsHelper

  def translation_path(arg, options={})
    translator_translation_path(arg,options)
  end

  def edit_translation_path(arg)
    edit_translator_translation_path(arg)
  end

  def new_translation_path
    new_translator_translation_path
  end

  def translations_path
    translator_translations_path
  end

  def translation_url(arg, options={})
    translator_translation_url(arg, options)
  end

  def sites_translation_link_list
    key = @translation.key.name
    language = @translation.language.code

    links = []
    url_params = { :controller => 'translations', :action => 'new', :key => key, :language => language}
    @sites.each do |site|
      link_params = url_params.dup
      link_params[:site_id] = site.id
      html_params = (site == @site) ? {:class => "active"} : {}
      links << link_to(site.title, link_params, html_params)
    end

    url_params[:site_id] = ""
    html_params = @site.blank? ? {:class => "active"} : {}

    links.unshift(link_to("Any Site", url_params, html_params))

    link_line(links)
  end
end
