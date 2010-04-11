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
    dup_names=Group.find(:all, :joins => "JOIN groups as b ON b.name = groups.name AND b.id != groups.id").map(&:name).uniq
    dup_names.each do |name|
      puts "There are multiple Groups with name %s." % name
      groups = Group.find_all_by_name(name)
      keep_me = groups.detect{|g| g.type = nil}
      keep_me ||= groups.detect{|g| g.type = 'Council'}
      keep_me ||= groups
      keep_me = keep_me.max{|a,b| a.users <=> b.users}
      groups.each do |g|
        if g == keep_me
          puts "Keeping: %s\t #%s has\t %s users and\t %s pages." %
            [g.type,g.id, g.users.count, g.pages.count]
        else
          puts "DELETING: %s\t #%s has\t %s users and\t %s pages." %
            [g.type,g.id, g.users.count, g.pages.count]
        end
      end
    end
  end
end
