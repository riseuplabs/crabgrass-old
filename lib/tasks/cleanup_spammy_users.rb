# this task cleans up spammy users
# in order to not overwhelm the database, it iterates backwards through time, one week at a time
# an inactive user is defined as a user who has no user_participations and no groups
# it will destroy users if:
#   * they match the pattern of spammy users found in june 2012
#   * a user is inactive and was last seen more than 30 days ago
#
# examples:
#  rake cg:cleanup_spammy_users
#   => will iterate backwards through every week until there are no more users
#
#  rake cg:cleanup_spammy_users quit_when_no_active_users=1
#   => will stop iterating when it finds a week when there are no inactive users

namespace :cg do
  task :cleanup_spammy_users => :environment do
    $stdout.puts "Cleaning up spammy users."
    week_num = 0
    only_inactive = ENV['quit_when_no_inactive_users']
    users = get_users(week_num, only_inactive)
    while users.count > 0
      $stdout.puts "Looking at week #{week_num.to_s}"
      june_2012_spammers = 0
      inactive_users = 0
      users.each do |user|
        inactive_user = only_inactive ? true : user_is_inactive?(user)
        if inactive_user
          if (user.login =~ /^\w+\d+$/) && (user.email =~ /hotmail\.com$/)
            june_2012_spammers += 1
          elsif user.last_seen_at.to_i > 30.days.ago.to_i
            inactive_users += 1
          end
        end
      end
      $stdout.puts "Found #{june_2012_spammers.to_s} recent spammers."
      $stdout.puts "Found #{inactive_users.to_s} other inactive users."
      week_num += 1
      users = get_users(week_num, only_inactive)
    end
  end

  def get_users(week_num, only_inactive=nil)
    users = User.find(:all, :conditions => "created_at < '#{week_num.weeks.ago}' and created_at > '#{(week_num+1).weeks.ago}'")
    return users unless only_inactive
    users.collect do |user|
      user_is_inactive?(user)
    end
  end

  def user_is_inactive?(user)
    participations = user.try(:user_participations)
    (participations.nil? || participations.empty?) && user.groups.empty?
  end
end
 
