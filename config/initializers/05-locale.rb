# The internationalization framework can be changed
# to have another default locale (standard is :en) or more load paths.
# All files from config/locales/*.rb,yml are added automatically.

lang_codes_in_database = Language.find(:all).collect {|language| language.code.to_s}

# glob all locales in the config/locales folder
locale_paths = Dir[File.join(Rails.root, 'config', 'locales', '**', '*.{rb,yml}')]
# select only enabled locales and locales that are exist in the db in 'languages' table
locale_paths = locale_paths.select do |path|
  # locales not enabled in Conf
  enabled_language = Conf.enabled_languages.blank? || Conf.enabled_languages.detect do |enabled_lang_code|
    path.include?("#{enabled_lang_code}.yml")
  end

  # locales not in the db
  language_in_db = lang_codes_in_database.detect do |code_in_db|
    path.include?("#{code_in_db}.yml")
  end

  # both must be true to consider this locale valid
  # for test don't need to look in the db, cause it's not ready
  enabled_language && (language_in_db || RAILS_ENV == "test")
end

# set the load paths
I18n.load_path << locale_paths
I18n.default_locale = :en
I18n.exception_handler = :crabgrass_i18n_exception_handler

def crabgrass_i18n_exception_handler(exception, locale, key, options)
  # see i18n.rb in activesupport gem
  # for the default I18n exception_handler
  if I18n::MissingTranslationData === exception
    if locale == :en
      return exception.message
    else
      options[:locale] = :en
      return I18n.translate(key, options)
    end
  end

  raise exception
end
