# =============================================================================
# A set of rake tasks for Crabgrass translation.
# =============================================================================

require 'fileutils'

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

namespace :cg do
  namespace :l10n do

    # This tasks extracts strings and its translation keys and dumps them
    # on 'lang/defaults_from_source.yml'. It's a bit of a hack, so check that  file before
    # loading the defaults into your db. If you specific FILE=filename, then only that
    # file is scanned.
    desc "Extract all texts prepared to be translated from Crabgrass source"
    task (:extract_keys) do
      count, keys, out = 0, [], "# Localization dictionary for the 'Gibberish' plugin (#{RAILS_ROOT.split ('/').last})\n\n"
      Dir["#{RAILS_ROOT}/app/**/*"].sort.each do |path|
          next if ENV['FILE'] && ENV['FILE'] != File.basename(path)
          unless ( matches = File.new(path).read.scan(/['"]([^'"]*)['"]((\.t)|\[\:([a-z1-9\_]*)(, [a-z1-9\_\.]*)*\])/)).empty?
            print "."
            out << "# -- #{File.basename(path)}:\n"
            matches.each do |m|
              m[2] = m[0].underscore.tr(' ', '_').gsub(/(\.|\!|\?)+$/, '') if m[2] == '.t'
              out << "#{m[2].gsub(/\%s/, '').gsub(/\_\_/, '_').gsub(/^\_|\_$/, '')}: #{m[0]}\n" unless (keys.include?(m[2]) || m[2].nil? || m[2] =~ /^(\_|\+)/)
              keys << m[2]
            end
            out << "\n"
            count +=1
          end if FileTest.file? path
      end
      FileUtils.mkdir_p File.join(RAILS_ROOT, 'lang') # Ensure we have lang dir
      File.open( File.join(RAILS_ROOT, 'lang', 'defaults_from_source.yml'), "w") { |file| file << out }
      puts "\nProcessed #{count} files and dumped YAML into #{RAILS_ROOT}/lang/defaults_from_source.yml"
    end

    # This tasks loads strings and its translation keys from 'lang/defaults_from_source.yml'.
    # It's a bit of a hack, so check that file before running this task.
    # Crabgrass development is in English, so this goes to the English "transation".
    desc "Load default values form Crabgrass source to be translated"
    task (:load_keys => :environment) do
      keys_hash = YAML::load_file(File.join(RAILS_ROOT, 'lang', 'defaults_from_source.yml'))
      keys_hash.each {|k,v| Key.create(:name => k)}
      default_language = Language.find_by_name('english')
      keys_hash.each do |k,v|
        key = Key.find_by_name(k)
        t = Translation.create(:text => v, :key => key, :language => default_language)
      end
    end

    # This taks get translations from the database and write to YAML files
    desc "Get translations from the database and write to YAML files"
    task(:extract_translations => :environment) do
      # Language model is not being overridden by Gibberize mod.
      # So we have to redefine it here.
      class Language < ActiveRecord::Base; has_many :translations; end

      # Ensure we have lang dir
      FileUtils.mkdir_p File.join(RAILS_ROOT, 'lang')

      # Get all available languages
      languages = Language.find :all

      # write a YAML file per language with the translations
      languages.each do |l|
        buffer = {}
        l.translations.each do |t|
          buffer[t.key.name] = t.text
        end
        if buffer.any?
          File.open('lang/' + l.code + '.yml', 'w') {|f| f.write(buffer.to_yaml) }
        end
      end
      puts "\nYAML files written to 'lang' directory\n"
    end

    # This tasks loads strings and its translation keys from 'lang/*.yml'.
    desc "Load translations from YAML files in the 'lang' directory"
    task (:load_translations => :environment) do
      Dir["#{RAILS_ROOT}/lang/*.yml"].sort.each do |lang_file|
        lang_code = File.basename(lang_file).split('.')[0]
        keys_hash = YAML::load_file(lang_file)
        language = Language.find_by_code(lang_code)
        if language
          keys_hash.each do |k,v|
            key = Key.find_or_create_by_name(k)
            t = Translation.create(:text => v, :key => key, :language => language)
          end
        else
          puts "Language '#{lang_code} does not exist in the database. Try running rake cg:load_default_data"
          exit
        end
      end
    end
    
    desc "Create a piglatin file for testing"
    task(:create_piglatin) do
      english = YAML::load_file(File.join(RAILS_ROOT, 'lang', 'en_US.yml'))
      piglatin = {}
      english.each do |k,v|
        piglatin[k] = v.split.map{|word| word.pig}.join(" ")
      end
      # piglatin is latin as spoken in the USA?
      File.open(File.join(RAILS_ROOT, 'lang', 'la_US.yml'), "w") do |outfile|
        YAML::dump(piglatin, outfile)
      end
    end
    
    desc "Enable piglatin in the app"
    task(:enable_piglatin => :environment) do
      Language.create(:name => "piglatin", :code => "la_US")
    end
  end
end
