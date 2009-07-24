module Gibberize::LanguagesHelper

  def language_path(arg, options={})
    gibberize_language_path(arg,options)
  end

  def edit_language_path(arg)
    edit_gibberize_language_path(arg)
  end

  def new_language_path
    new_gibberize_language_path
  end

  def languages_path
    gibberize_languages_path
  end

  def language_url(arg, options={})
    gibberize_language_url(arg, options)
  end
end
