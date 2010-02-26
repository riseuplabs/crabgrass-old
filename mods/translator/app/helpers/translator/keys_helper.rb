module Translator::KeysHelper

  def key_path(arg, options={})
    translator_key_path(arg,options)
  end

  def edit_key_path(arg)
    edit_translator_key_path(arg)
  end

  def keys_path
    translator_keys_path
  end

  def key_url(arg, options={})
    translator_key_url(arg, options)
  end

  def key_navigation_links
    if @language
      link_line(
        link_to_active("translated", {:controller => 'keys', :language => @language.to_param, :filter => 'translated'}),
        link_to_active("untranslated", {:controller => 'keys', :language => @language.to_param, :filter => 'untranslated'}),
        link_to_active("out of date", {:controller => 'keys', :language => @language.to_param, :filter => 'out_of_date'}),
        link_to_active("all keys", {:controller => 'keys', :language => @language.to_param, :filter => 'all'}),
        link_to_active("search", {:controller => 'keys', :language => @language.to_param, :filter => 'search'})
      )
    else
      link_line(
        link_to_active('all keys', {:controller => 'keys', :action => nil, :filter => nil}),
        link_to_active("search", {:controller => 'keys', :action => nil, :filter => 'search'}),
      )
    end
  end

  def translate_key_languages_links(site = @site)
    site_id = site.blank? ? "" : site.id

    links = []
    @languages.each { |language|
      if @key.translations.for_language(language).for_site(site).blank?
        links << link_to(language.name, :controller => :translations,
                                        :action => :new,
                                        :key => @key.name,
                                        :language => language,
                                        :site_id => site_id)
      end
    }
    links.join("\n")
  end
end
