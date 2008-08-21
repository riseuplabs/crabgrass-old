# Rake task to extract texts from Ruby/ERb source in your application
# Scans patterns like "Hello World"[:hello_world] and dumps them into RAILS_ROOT/lang/new_language.yml
# TODO: Process incrementally, ie. dump newly added strings into existing localization files
# taken from http://gist.github.com/4068/
 
require 'fileutils'
 
namespace :cg do
  namespace :l10n do
  desc "Extract all texts prepared to be translated from Ruby source"
  task :extract_keys do
    count, keys, out = 0, [], "# Localization dictionary for the 'Gibberish' plugin (#{RAILS_ROOT.split('/').last})\n\n"
    Dir["#{RAILS_ROOT}/app/**/*"].sort.each do |path|
        unless ( matches = File.new(path).read.scan(/['"]([^'"]*)['"]\[\:([a-z1-9\_]*)\]/) ).empty?
          print "."
          out << "# -- #{File.basename(path)}:\n"
          matches.each do |m|
            out << "#{m[1]}: #{m[0]}\n" unless keys.include? m[1]
            keys << m[1]
          end
          out << "\n"
          count +=1
        end if FileTest.file? path
    end
    FileUtils.mkdir_p File.join(RAILS_ROOT, 'lang') # Ensure we have lang dir
    File.open( File.join(RAILS_ROOT, 'lang', 'default.yml'), "w") { |file| file << out }
    puts "\nProcessed #{count} files and dumped YAML into #{RAILS_ROOT}/lang/default.yml"
  end
end
end
