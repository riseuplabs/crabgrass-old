# The internationalization framework can be changed
# to have another default locale (standard is :en) or more load paths.
# All files from config/locales/*.rb,yml are added automatically.
I18n.load_path <<  Dir[File.join(RAILS_ROOT, 'config', 'locales', '**', '*.{rb,yml}')]
I18n.default_locale = :en