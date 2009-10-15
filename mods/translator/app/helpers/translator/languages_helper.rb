module Translator::LanguagesHelper

  def language_path(arg, options={})
    translator_language_path(arg,options)
  end

  def edit_language_path(arg)
    edit_translator_language_path(arg)
  end

  def new_language_path
    new_translator_language_path
  end

  def languages_path
    translator_languages_path
  end

  def language_url(arg, options={})
    translator_language_url(arg, options)
  end
end
