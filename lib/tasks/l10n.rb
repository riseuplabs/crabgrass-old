# =============================================================================
# A set of rake tasks for Crabgrass translation.
# =============================================================================
$KCODE = 'UTF8'

require 'fileutils'
LANG_DIR = "#{Rails.root}/config/locales"

class String
  def pig
    return self unless self =~ /^[a-z]/i

    self =~ /^([a-z]*)(.*)$/i
    word = $1
    punctuation = $2
    leadingCap = word =~ /^[A-Z]/
    word.downcase!
    res = case word
      when /^[aeiouy]/
        word+"way"
      when /^([^aeiouy]+)(.*)/
        $2+$1+"ay"
      else
        word
    end
    (leadingCap ? res.capitalize : res) + punctuation
  end
end


def load_locale_data(language, site, dictionary)
  site_id = site ? site.id : nil

  canonical_language = Language.find_by_code("en")

  dictionary.each do |k, text|
    if (language == canonical_language) && site.nil?
      key = Key.find_or_create_by_name(k)
    else
      key = Key.find_by_name(k)
    end
    if key.nil?
      print "(skip:%s)" % k
      next
    end

    if t = Translation.find_by_key_id_and_language_id_and_site_id(key.id,language.id, site_id)
      if t.text == text
        putc '.'
      else
        print "(UPDATE:%s)" % k
        t.update_attributes(:text => text)
      end
    elsif !text.blank?
      Translation.create(:text => text, :key => key, :language => language, :site_id => site_id)
      putc '*'
    end
    $stdout.flush
  end
  putc "\n"; $stdout.flush
end

def load_locale_file(path)
  puts "\nLoading #{path}"
  site_specific = File.dirname(path).match(/sites\/.+$/)

  data = YAML::load_file(path)

  data.each do |language_code, sites_or_dictionary|
    # language code: en, zh, el, etc.
    language = Language.find(:first, :conditions => ["code LIKE ?", "#{language_code}%"])
    unless language
      puts "Warning: language #{language_code} in #{path} does not exist!"
      next
    end

    if site_specific
      sites_or_dictionary.each do |site_name, dictionary|
        site = Site.find_by_name(site_name)
        unless site
          puts "Warning: site #{site_name} in #{path} does not exist!"
          next
        end
        load_locale_data(language, site, dictionary)
      end
    else
      dictionary = sites_or_dictionary
      load_locale_data(language, nil, dictionary)
    end
  end
end

def dump_locale_file(langcode, sitename, dictionary)
  if dictionary.blank?
    puts "No dictionary for language #{langcode} on site #{sitename}"
    return
  end

  pathparts = [LANG_DIR]
  pathparts += ["sites", sitename] if sitename

  dirpath = File.join(pathparts)
  path = File.join(dirpath, "#{langcode}.yml")

  FileUtils.mkdir_p dirpath

  buffer = {}
  if sitename
    buffer[langcode] = {sitename => dictionary}
  else
    buffer[langcode] = dictionary
  end

  if buffer.any?
    File.open(path, 'w') {|f| f.write(buffer.ya2yaml) }
    puts "Wrote #{path}"
  end
end

def dump_all_locales(data)
  ### data contain each language as the top key, sites as subkeys, and dictionaries under sites
  # {
  #   'en' => { nil     => {"key1" => "words", "key2" => "more words"},
  #            "site1"  =>  "key1" => "special words for site" }}
  #   'ar' => ...
  # }

  data.each do |langcode, sites|
    sites.each do |sitename, dictionary|
      dump_locale_file(langcode, sitename, dictionary)
    end
  end

end

namespace :cg do
  namespace :l10n do

    # This task get translations from the database and write to YAML files
    desc "Get translations from the database and write to YAML files"
    task(:extract_translations => :environment) do
      # Language model is not being overridden by translator mod.
      # So we have to redefine it here.
      class Language < ActiveRecord::Base; has_many :translations; end

      # Get all available languages
      languages = Language.find :all

      # [langcode,...] => [sitename (or nil),...] => [{key => text}, ...]
      buffer = {}

      site_names = Site.all.inject({}) do |site_name_map, site|
        site_name_map[site.id] = site.name
        site_name_map
      end

      # write a YAML file per language with the translations
      languages.each do |l|
        # two letter language code ('en', 'ar', etc.)
        langcode = l.code[0, 2]

        l.translations.each do |t|
          sitename = site_names[t.site_id]

          # quit the script if can't figure out the site name
          # don't want to drop site specific translations into general yml files
          if !t.site_id.nil? and sitename.nil?
            raise "Translation #{t.id} has site_id #{t.site_id}, but no such site can be found"
          end

          # store the translations in a hierarchical buffer
          buffer[langcode] ||= {}
          buffer[langcode][sitename] ||= {}
          buffer[langcode][sitename][t.key.name] = t.text
        end

        # don't overwrite canonical translations
        if buffer['en'] and buffer['en'][nil].is_a? Hash
          buffer['en'].delete(nil)
        end
      end

      dump_all_locales(buffer)
      puts "\nYAML files written to 'config/locales' directory\n"
    end

    # This tasks loads strings and its translation keys from 'config/locales/*.yml'.
    desc "Load translations from YAML files in the 'lang' directory"
    task (:load_translations => :environment) do
      if ENV["FILE"]
        load_locale_file(File.join(LANG_DIR, ENV["FILE"]))
      else
        canonical_file = File.join(LANG_DIR, "en.yml")

        # put the canonical file first in the list
        all_files = Dir["#{LANG_DIR}/**/*.yml"] - [canonical_file]
        all_files.unshift(canonical_file)

        all_files.each do |lang_file|
          load_locale_file(lang_file)
        end

      end
    end

    desc "Create a piglatin file for testing"
    task(:create_piglatin) do
      english = YAML::load_file(File.join(LANG_DIR, 'en.yml'))
      piglatin = {}
      english.each do |k,v|
        piglatin[k] = v.split.map{|word| word.pig}.join(" ")
      end
      # piglatin is latin as spoken in the USA?
      File.open(File.join(LANG_DIR, 'la_US.yml'), "w") do |outfile|
        YAML::dump(piglatin, outfile)
      end
    end

    desc "Enable piglatin in the app"
    task(:enable_piglatin => :environment) do
      Language.create(:name => "piglatin", :code => "la_US")
    end


  end
end
