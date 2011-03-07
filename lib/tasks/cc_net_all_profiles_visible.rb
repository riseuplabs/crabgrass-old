namespace :cg do
  task :cc_net_all_profiles_visible => :environment do
    Profile.find(:all).each do |prof|
      next unless prof.entity.is_a? User
      prof.update_attribute('may_see', 1)
      prof.save!
    end
  end
end
