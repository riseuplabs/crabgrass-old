#!/usr/bin/ruby1.9
require 'yaml'

class Object
  def blank?
    self.nil? ||  (self.respond_to?(:empty?) and self.empty?)
  end
end

$dictionary_supplement = {}
$dictionary_supplement_locations = {}

$total = 0
$print_replaced = true
$print_reading_file = false
$writefile = true

def key_exists?(key)
  $dictionary.keys.include?(key)
end

def replace_line(line, location_info)
  old_line = line.dup
  replaced = true
  warnings = []
  key = nil
  default_string = nil

  case line
  # "hello there"[:welcome_greeting]
  when /(.*[^"'])(["'])(.+?)\2\[:(\S+?)\s*\]/
    line_type = '("hello there"[:welcome_greeting])'
    prefix = $1
    default_string = $3
    key = $4
    line.sub!(/(.*[^"'])(["'])(.+?)\2\[:(\S+?)\s*\]/, "#{prefix}I18n.t(:#{key})")
  # <%= "You are logged in as {login}"[:login_info, h(current_user.login)] %>
  when /(["'])([^\1]+)\1\[(:\S+),\s*(\S+[^\]]+)\]/
    line_type = '(MACRO "You are logged in as {login}"[:login_info, h(current_user.login)])'
    matched_part = $&
    # break up string into "You are logged in as {login}" and
    # ":login_info, h(current_user.login)"
    default_string = $2
    key = $3
    args = $4

    # i found at least one case like: 'default {var}'[:key, {:var => value}]
    if args =~ /\{\s*(:[^\}]+)\}/
      newline = "I18n.t(#{key}, "+ $1 + ')'
    else
      args = args.split(/,/)
      # this will return ["login"], and any other strings within {}
      placeholders = default_string.scan(/(?<=\{)[^\}]+(?=\})/)
      newline = "I18n.t(#{key}"
      # i found at least one case like: 'default look no vars'[:key, arg]
      # notice no {arg} in the default string.
      # not sure what to do with these - can use index i guess
      # but it will likely have to be fixed manually.
      args.each do |arg|
        ph = placeholders[args.index(arg)] || args.index(arg)
        warnings << "unknown key '#{arg}' in #{line}" if ph.is_a? Numeric
        newline << ", :#{ph} => #{arg}"
      end
#          placeholders.each do |ph|
#            # I18n.t(:login_info, :login => h(current_user.login))
#            newline << ", :#{ph} => "+ args[placeholders.index(ph)]
#          end
      newline << ')'
    end
    # this would be better but i'm having trouble escaping matched_part (sleepyyyy)
    # line.gsub!(/#{matched_part}/, newline)
    line.sub!(/(["'])[^\1]+\1\[:\S+,\s*\S+[^\]]+\]/, newline)
##########
########## this is really hairy stuff that might need to be fixed manually
########## since i think these strings need to be looked up in the yaml files
  ## 1: "you have been invited to join %s"[:network_invite] % network.name
  ## 2: "blah invited to join :network_name"[:network_invite] % {:network_name => network.name}
  ## 3: "blah blah %s/yourgroupname. blah %s/username"[:key] % [value1, value2]
  when /(['"])([^\1]+)\1\[(:\S+)\]\s+%\s+(\S[^%]+)\s+%?/
    line_type = '(OLD MACRO!!!)'
    default_string = $2
    key = $3
    args = $4
    # again, not sure what to do with unnamed placeholders in the default string
    newline = "I18n.t(#{key}"
    if args =~ /^\S+$/ # 1
      warnings << "unknown key in #{line}"
      newline << ", :1 => #{args})"
    elsif args =~ /^\{/ #2
      args.gsub!(/[\{\}]/, '')
      newline << ", #{args})"
    elsif args =~ /^\[/ #3
      args.gsub!(/[\[\]]/, '')
      args.split(/,/).each do |arg|
        warnings << "unknown key '#{arg}' in #{line}"
        newline << ', :' + args.index(arg).to_s + " => #{arg}"
      end
      newline << ")"
    end
    line.sub!(/(['"])[^\1]+\1\[:\S+\]\s+%\s+\S[^%]+/, newline)
##########
########## end deprecated macros
##########
  # :version_number.t % {:version => version.version, :or_more_args => more.args}
  when /\s:(\S+)\.t\s*%\s*\{([^\}]+)\}/
    line_type = '(:version_number.t % {:version => version.version, :or_more_args => more.args})'
    key = $1
    line.sub!(/:(\S+)\.t\s*%\s*\{([^\}]+)\}/,'I18n.t(:\1, \2)')
  # :welcome_greeting.t
  when /:(\w+)\.t(\W)/
    line_type = '(:welcome_greeting.t)'
    key = $1
    line.sub!(/:(\w+)\.t(\W)/, 'I18n.t(:\1)\2')
  # "hello there".t
  when /(.*[^"'])(['"])(.+?)\2\.t(\W)/
    line_type = '("hello there".t)'
    prefix = $1
    default_string = $3
    suffix = $4
    key = $3.downcase.gsub(/\s/, '_')
    line.sub!(/(.*[^"'])(['"])(.+?)\2\.t\W/, "#{prefix}I18n.t(:#{key})#{suffix}")
  # _('Hello There')
  when /_\((['"])(.+?)\1\)([\s,\.])/
    line_type = "_('Hello There')"
    default_string = $2
    suffix = $3
    key = $2.downcase.gsub(/\s/, '_')
    line.sub!(/_\((['"])(.+?)\1\)[\s,\.]/, "I18n.t(:#{key})#{suffix}")
  else
    replaced = false
  end

  if replaced and $print_replaced
    puts "\n\t\t-- type: #{line_type} --"
    # puts "* KEY:     '#{key}'"
    # puts "* DEFAULT: '#{default_string}'"
    puts "   from: #{old_line}"
    puts "   out:  #{line}\n"
    $total += 1
  end


  if key
    key = key.to_s.gsub(/^:/, "")
    unless key_exists?(key)
      if default_string.blank?
        warnings << "TOTALLY missing translation key: '#{key}' !!!"
      else
        warnings << "missing translation key: '#{key}' with default string: \"#{default_string}\""
      end
      $dictionary_supplement[key] = default_string
      $dictionary_supplement_locations[key] ||= []
      $dictionary_supplement_locations[key] << location_info
    end
  end

  return warnings, replaced
end

def checkfile(filename)
  file_warnings = {}
  puts " ---- READING #{filename}" if $print_reading_file

  lines = []
  replaced = false
  File.open(filename) do |file|
    line_index = 1
    while line = file.gets
      location_info = "#{filename}:#{line_index}"
      keep_trying = true
      while keep_trying
        line_warnings, keep_trying = replace_line(line, location_info)
        replaced ||= keep_trying
        unless line_warnings.empty?
          file_warnings[line_index] = line_warnings
        end
      end

      lines << line
      line_index += 1
    end
  end

  writefile(filename, lines) if replaced and $writefile
  file_warnings
end

def writefile(filename, lines)
  File.open(filename, "w") do |file|
    lines.each {|line| file.puts line}
  end
end

def ruby_code_file?(file)
  return false if file =~ /^\./
  return false if file =~ /\.(jar|jpg|png|swf|xcf|gz|log|dia|ico|svg|beam|sp\w|doc|yml|pdf|rd|gif|tiff|js|sqlite3)$/i
  return false if file =~ /gibberish|fixsource\.rb|coderay|multiple_select|ruby_sess\./

  true
end
def searchdirectory(directory)
  dir_warnings = {}
  Dir.open(directory) do |dir|
    dir.each do |file|
      next unless ruby_code_file? file
      path_to_file = File.join(dir.path, file)
      if File.file?(path_to_file)
        file_warnings = checkfile(path_to_file)
        dir_warnings[path_to_file] = file_warnings unless file_warnings.empty?
      elsif File.directory?(path_to_file)
        dir_warnings.merge!(searchdirectory(path_to_file))
      end
    end
  end

  dir_warnings
end

def print_warnings_banner
  puts "\n--------------"
  puts "---WARNINGS---"
  puts ""
end

def print_dir_warnings(dir_warnings)
  dir_warnings.keys.sort.each do |file|
    file_warnings = dir_warnings[file]
    print_file_warnings(file, file_warnings)
  end
end

def print_file_warnings(file, warnings)
  puts "#{file}"
  warnings.each do |line, messages|
    messages.each do |msg|
      puts ("  %3d: " % line) + msg
    end
  end
  puts ""
end

def print_dictionary_supplement
  puts "\n============================="
  puts "=== DICTIONARY SUPPLEMENT ===\n\n"
  $dictionary_supplement.keys.sort.each do |key|
    default_string = $dictionary_supplement[key]
    puts "#{key}: \"#{default_string}\""
    locations = $dictionary_supplement_locations[key]
    locations.each do |location|
      puts "   in #{location}"
    end
    puts

  end
end

input = ARGV[0] || './'

warnings = nil

$dictionary = YAML.load_file("config/locales/en.yml")["en"]

if File.file?(input)
  warnings = checkfile(input)
  print_warnings_banner
  print_file_warnings(input, warnings) unless warnings.empty?
  print_dictionary_supplement
elsif File.directory?(input)
  warnings = searchdirectory(input)

  print_warnings_banner
  print_dir_warnings(warnings)
  print_dictionary_supplement
else
  puts input+': not a file or directory!'
end


puts "TOTAL: #{$total}"
