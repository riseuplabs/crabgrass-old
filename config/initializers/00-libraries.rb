# Check out if the git submodules are updated if not we print a warning message and exit
outdate_msg = "\n\nYou have to update your git submodules\n\nThe appropriate way is: $ git submodule update --init\n\n"
outdated = 0
submodules = `git submodule`
submodules.each do |line|
  if m = line.match(/([0-9a-f]{40})\s(.+)\s\(/)
    needed_commit = m[1]; dir = m[2]

    begin
      current_commit = `cd #{RAILS_ROOT}/#{dir} && git log -n 1 --pretty=format:%H`
    rescue
      current_commit = ''
    end
    
    outdated +=1 if current_commit != needed_commit
  end
end

if outdated > 0
  print outdate_msg
  exit
end

%w(string core action_pack active_record active_record_validations engines).each do |file|
  require "#{RAILS_ROOT}/lib/extension/#{file}"
end

require "#{RAILS_ROOT}/lib/uglify_html/lib/uglify_html.rb"
require "#{RAILS_ROOT}/lib/greencloth/greencloth.rb"
require "#{RAILS_ROOT}/lib/undress/lib/undress/greencloth.rb"
require "#{RAILS_ROOT}/lib/path_finder.rb"
require "#{RAILS_ROOT}/lib/i18n_helpers.rb"

# model extensions:
require "#{RAILS_ROOT}/app/models/tag.rb"
