# =============================================================================
# A set of rake tasks for Crabgrass translation.
# =============================================================================

require 'fileutils'

namespace :cg do
  namespace :l10n do

    # This tasks extracts strings and its translation keys and dumps them
    # on 'lang/default.yml'. It's a bit of a hack, so check that  file before
    # loading the defaults into your db.
    desc "Extract all texts prepared to be translated from Crabgrass source"
    task (:extract_keys) do
      count, keys, out = 0, [], "# Localization dictionary for the 'Gibberish' plugin (#{RAILS_ROOT.split ('/').last})\n\n"
      Dir["#{RAILS_ROOT}/app/**/*"].sort.each do |path|
          unless ( matches = File.new(path).read.scan(/['"]([^'"]*)['"]((\.t)|\[\:([a-z1-9\_]*)(, [a-z1-9\_\.]*)*\])/)).empty?
            print "."
            out << "# -- #{File.basename(path)}:\n"
            matches.each do |m|
              m[2] = m[0].underscore.tr(' ', '_').gsub(/(\.|\!|\?)+$/, '') if m[2] == '.t'
              out << "#{m[2]}: #{m[0]}\n" unless (keys.include?(m[2]) || m[2].nil? || m[2] =~ /^(\_|\+)/)
              keys << m[2]
            end
            out << "\n"
            count +=1
          end if FileTest.file? path
      end
      FileUtils.mkdir_p File.join(RAILS_ROOT, 'lang') # Ensure we have lang dir
      File.open( File.join(RAILS_ROOT, 'lang', 'default.yml'), "w") { |file| file << out }
     puts "\nProcessed #{count} files and dumped YAML into #{RAILS_ROOT}/lang/default.yml"
    end

    # This tasks loads strings and its translation keys from 'lang/default.yml'.
    # It's a bit of a hack, so check that file before running this task.
    desc "Load default values form Crabgrass source to be transated"
    task (:load_keys => :environment) do
      keys_hash = YAML::load_file(File.join(RAILS_ROOT, 'lang', 'default.yml'))
      keys_hash.each {|k,v| Key.create(:name => k)}
      default_language = Language.find_by_name('english')
      keys_hash.each do |k,v|
        key = Key.find_by_name(k)
        t = Translation.create(:text => v, :key => key, :language => default_language)
      end
    end
  end
end
