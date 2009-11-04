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
