# The internationalization framework can be changed
# to have another default locale (standard is :en) or more load paths.
# All files from config/locales/*.rb,yml are added automatically.
I18n.load_path <<  Dir[File.join(RAILS_ROOT, 'config', 'locales', '**', '*.{rb,yml}')]
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