namespace :cg do
  task :cc_net_remove_friends => :environment do
    User.find(:all).each do |user|
      user.friends.each do |f|
        user.remove_contact! f
        user.update_contacts_cache
      end
    end
  end
end
