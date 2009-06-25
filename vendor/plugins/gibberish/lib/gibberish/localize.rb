module Gibberish
  module Localize
    @@default_language = :en
    mattr_reader :default_language

    @@reserved_keys = [ :limit ]
    mattr_reader :reserved_keys

    def add_reserved_key(*key)
      (@@reserved_keys += key.flatten).uniq!
    end
    alias :add_reserved_keys :add_reserved_key

    @@languages = {}
    def languages
      @@languages.keys
    end

    @@current_language = nil
    def current_language
      @@current_language || default_language
    end

    def current_language=(language)
      #load_languages! if defined?(RAILS_ENV) && RAILS_ENV == 'development'

      language = language.to_sym if language.respond_to? :to_sym
      @@current_language = @@languages[language] ? language : nil
    end

    def use_language(language)
      start_language = current_language
      self.current_language = language
      yield
      self.current_language = start_language
    end

    def default_language?
      current_language == default_language
    end

    def translations(lang=nil)
      lang ||= current_language
      @@languages[lang] || {}
    end

    def translate(string, key, *args)
      return if reserved_keys.include? key
      target = translations[key] || string
      ## crabgrass hack: default to english if empty target
      target = (translations(:en)[key] || "") if target.empty?
      ## end crabgrass hack
      interpolate_string(target.dup, *args.dup)
    end

    def load_languages!
      language_files.each do |file| 
        key = File.basename(file, '.*').to_sym
        @@languages[key] ||= HashWithIndifferentAccess.new
        # crabgrass hack     ^^^^^^ made the translations hash be indifferent.
        @@languages[key].merge! YAML.load_file(file).symbolize_keys

        # crabgrass hack: alias en_US to en, fr_FR to fr, etc.
        if key.to_s =~ /_/
          key_without_local = key.to_s.sub(/_\w\w$/,'').to_sym
          @@languages[key_without_local] = @@languages[key]
        end
      end
      languages
    end

    @@language_paths = [RAILS_ROOT]
    def language_paths
      @@language_paths ||= []
    end
  private
    def interpolate_string(string, *args)
      if args.last.is_a? Hash
        interpolate_with_hash(string, args.last)
      else
        interpolate_with_strings(string, args)
      end
    end

    def interpolate_with_hash(string, hash)
      hash.inject(string) do |target, (search, replace)|
        target.sub("{#{search}}", replace)
      end 
    end

    def interpolate_with_strings(string, strings)
      string.gsub(/\{\w+\}|%s/) { strings.shift }
    end
   
    ## crabgrass hack: added *.custom.yml 
    def language_files
      @@language_paths.map {|path| Dir[File.join(path, 'lang', '*.{yml,yaml}')]}.flatten + 
      @@language_paths.map {|path| Dir[File.join(path, 'lang', 'custom', '*.{yml,yaml}')]}.flatten
    end
  end
end
