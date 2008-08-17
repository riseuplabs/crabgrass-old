module Gibberize::TranslationsHelper

  def translation_path(arg, options={})
    gibberize_translation_path(arg,options)
  end

  def edit_translation_path(arg)
    edit_gibberize_translation_path(arg)
  end
 
  def new_translation_path
    new_gibberize_translation_path
  end

  def translations_path
    gibberize_translations_path
  end

  def translation_url(arg, options={})
    gibberize_translation_url(arg, options)
  end
end
