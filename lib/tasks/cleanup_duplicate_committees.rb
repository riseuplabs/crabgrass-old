=begin

When committees (and councils) were created in the past their names where not
checked for conflicts. They can have the same name as the parent name will
be prepended. But two committees in the same group should not have the same name.

We now validate this but old committees might still be around and invalid. So saving
the committees will fail. Therefore this task removes duplicate committees and
tries to guess which one is the actually used one.

=end

namespace :cg do
  desc "removes duplicate committees - their names are invalid as a handle."
  task(:cleanup_duplicate_committees => :environment) do
    unless ENV['USER'] && destructor = User.find_by_login(ENV['USER'])
      puts 'ERROR: user login required, use USER=<name> to specify.'
      puts '       The corresponding user will be used for deleting the groups.'
      exit
    end

    dup_names=Group.find(:all, :joins => "JOIN groups as b ON b.name = groups.name AND b.id != groups.id").map(&:name).uniq
    dup_names.each do |name|
      puts "There are multiple Groups with name %s." % name
      groups = Group.find_all_by_name(name)
      keep_me = groups.detect{|g| g.type == nil}
      keep_me ||= groups.detect{|g| g.type == 'Council' && g.parent}
      keep_me ||= groups.detect{|g| g.parent}
      keep_me = keep_me.max{|a,b| a.users.count <=> b.users.count} if keep_me.is_a? Array
      groups.each do |g|
        if g == keep_me
          puts "Keeping: %s #%s has %s users and %s pages." % [g.type,g.id, g.users.count, g.pages.count]
          g.clean_names
          new_name = g.name
          puts "Renaming to %s." % new_name if new_name != name
        else
          puts "DELETING: %s #%s has %s users and %s pages." % [g.type,g.id, g.users.count, g.pages.count]
          if g.parent
            g.destroy_by(destructor)
          else
            Group.delete_all("id = %s" % g.id)
          end
        end
      end
    end
  end
end
