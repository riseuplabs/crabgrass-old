# The internationalization framework can be changed
# to have another default locale (standard is :en) or more load paths.
# All files from config/locales/*.rb,yml are added automatically.

# glob all locales in the config/locales folder
locale_paths = Dir[File.join(Rails.root, 'config', 'locales', '**', '*.{rb,yml}')]

# select only enabled locales unless no enabled locales are set
unless Conf.enabled_languages.blank?
  locale_paths = locale_paths.select do |path|
    Conf.enabled_languages.detect do |enabled_lang_code|
      path.include?("#{enabled_lang_code}.yml")
    end
  end
end

# set the load paths
I18n.load_path << locale_paths
I18n.default_locale = :en
I18n.exception_handler = :crabgrass_i18n_exception_handler
