=begin

When pages were destroyed in the past, they did not clean up their data.
This task will search for orphaned page data and destroy it if it is not
associated with any page.

NOTE: this task will fail if you have upgraded to the crabgrass revision
with the new asset system but not yet run this migration. This migration
requires the old asset.rb. As a hack, you can copy the old asset.rb to app/models
and rename app/models/assets to app/models/assets.disabled in order to run this
task.

=end

namespace :cg do
  desc "removes page data that should have been deleted."
  task(:cleanup_orphaned_data => :environment) do 
    [TaskList, Poll, Asset].each do |data_class|
      data_class.find(:all).each do |data|
        if data.pages.empty? and data.page.nil?
          puts "%s id %s is missing a page! destroying record." % [data_class, data.id]
          data.destroy
        end
      end
    end
    Wiki.find(:all).each do |wiki|
      if wiki.pages.empty? and wiki.profile.nil?
        puts "wiki id %s does not have a page or a profile! destroying wiki." % wiki.id
        wiki.destroy
      end
    end
  end
end
