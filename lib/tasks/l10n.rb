# =============================================================================
# A set of rake tasks for Crabgrass translation.
# =============================================================================

require 'fileutils'

LANG_DIR = "#{RAILS_ROOT}/lang"
CUSTOM_LANG_DIR = "#{LANG_DIR}/custom"

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

def load_language_file(lang_file, options={})
  lang_code = File.basename(lang_file).split('.')[0]
  keys_hash = YAML::load_file(lang_file)
  language = Language.find_by_code(lang_code)
  custom = options[:custom] == true
  if language
    print 'loading %s' % lang_file
    keys_hash.each do |k,v|
      key = Key.find_or_create_by_name(k)
      if t = Translation.find_by_key_id_and_language_id(key.id,language.id)
        if t.text == v
          putc '.'
        else
          print "(update:%s)" % k
          t.update_attributes(:text => v, :custom => custom) 
        end
      else
        Translation.create(:text => v, :key => key, :language => language, :custom => custom)
        putc '*'
      end
      $stdout.flush
    end
    putc "\n"; $stdout.flush
  else
    puts "skipping language '#{lang_code}' (does not exist in the database)"
  end
end

namespace :cg do
  namespace :l10n do

    # This tasks extracts strings and its translation keys and dumps them
    # on 'lang/defaults_from_source.yml'. It's a bit of a hack, so check that  file before
    # loading the defaults into your db. If you specific FILE=filename, then only that
    # file is scanned.

=begin
 I don't think this actually works, and we shouldn't use it

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
=end

    # This tasks loads strings and its translation keys from 'lang/defaults_from_source.yml'.
    # It's a bit of a hack, so check that file before running this task.
    # Crabgrass development is in English, so this goes to the English "transation".

=begin
 I don't think this should ever be used

    desc "Load default values form Crabgrass source to be translated"
    task (:load_keys => :environment) do
      keys_hash = YAML::load_file(File.join(RAILS_ROOT, 'lang', 'defaults_from_source.yml'))
      keys_hash.each {|k,v| Key.create(:name => k)}
      default_language = Language.find_by_code('en_US')
      keys_hash.each do |k,v|
        key = Key.find_by_name(k)
        t = Translation.create(:text => v, :key => key, :language => default_language)
      end
    end
=end

    # This task get translations from the database and write to YAML files
    desc "Get translations from the database and write to YAML files"
    task(:extract_translations => :environment) do
      # Language model is not being overridden by Gibberize mod.
      # So we have to redefine it here.
      class Language < ActiveRecord::Base; has_many :translations; end

      # Ensure we have lang dir
      FileUtils.mkdir_p LANG_DIR
      FileUtils.mkdir_p CUSTOM_LANG_DIR

      # Get all available languages
      languages = Language.find :all

      # write a YAML file per language with the translations
      languages.each do |l|
        ## global translations
        if l.code != 'en_US'
          buffer = {}
          l.translations.each do |t|
            buffer[t.key.name] = t.text unless t.custom?
            # ^^ (the custom check should not be needed, but it is. why?)
          end
          if buffer.any?
            File.open(LANG_DIR + '/' + l.code + '.yml', 'w') {|f| f.write(buffer.to_yaml) }
          end
        end
        ## custom translations
        buffer = {}
        l.custom_translations.each do |t|
          buffer[t.key.name] = t.text
        end
        if buffer.any?
          File.open(CUSTOM_LANG_DIR + '/' + l.code + '.yml', 'w') {|f| f.write(buffer.to_yaml) }
        end
      end
      puts "\nYAML files written to 'lang' directory\n"
    end

    # This tasks loads strings and its translation keys from 'lang/*.yml'.
    desc "Load translations from YAML files in the 'lang' directory"
    task (:load_translations => :environment) do
      Dir["#{LANG_DIR}/*.yml"].sort.each do |lang_file|
        load_language_file(lang_file, :custom => false)
      end
      Dir["#{CUSTOM_LANG_DIR}/*.yml"].sort.each do |lang_file|
        load_language_file(lang_file, :custom => true)
      end
    end
    
    desc "Create a piglatin file for testing"
    task(:create_piglatin) do
      english = YAML::load_file(File.join(LANG_DIR, 'en_US.yml'))
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
