module translator::TranslationsHelper

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
end
