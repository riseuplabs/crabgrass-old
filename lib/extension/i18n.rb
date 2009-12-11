module I18n
  class << self
    def language_for_locale(locale)
      load_available_languages if @languages.blank?
      @languages[locale.to_sym]
    end

    def available_languages
      load_available_languages if @languages.blank?
      @languages.values.sort_by(&:id)
    end

    def site_scope
      Site.current.try.name.try.to_sym
    end

    def translate_with_site_scope(key, options = {})
      if site_scope
        locale = options[:locale] || I18n.locale
        keys = I18n.send(:normalize_translation_keys, locale, key, options[:scope])

        # leave only scope components
        keys.delete(locale)
        keys.delete(key)

        # make site scope the top scope
        keys.unshift(site_scope)

        # use this new scope
        options[:scope] = keys
      end

      translate_without_site_scope(key, options)
    end

    alias_method_chain :translate, :site_scope
    alias_method :t, :translate_with_site_scope

    protected

    def load_available_languages
      #  @languages = {
      #   :en => #<Language code:"en" ...>,
      #   :es => #<Language code:"es" ..>
      #  }

      @languages = {}
      I18n.available_locales.each do |code|
        @languages[code] = Language.find_by_code(code.to_s)
      end
    end
  end
end


def crabgrass_i18n_exception_handler(exception, locale, key, options)
  # see i18n.rb in activesupport gem
  # for the default I18n exception_handler
  if I18n::MissingTranslationData === exception

    # try falling back to non-site specific translations
    keys = I18n.send(:normalize_translation_keys, locale, key, options[:scope])
    if keys.include?(I18n.site_scope)
      # keys = [:en, :thediggers, :some_other_scope, :title]
      # delete everything except :some_other_scope
      keys.delete(I18n.site_scope)
      keys.delete(locale)
      keys.delete(key)

      options[:scope] = keys
      options[:locale] = locale

      # try the same key but without site scope
      return  I18n.translate_without_site_scope(key, options)
    elsif locale == :en
      return exception.message
    else
      options[:locale] = :en
      return I18n.translate(key, options)
    end
  end

  raise exception
end
