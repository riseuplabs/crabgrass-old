=begin

When pages were destroyed in the past, they did not clean up their data.
This migration will search for orphaned page data and destroy it if it is not
associated with any page.

=end

class CleanUpOrphanedData < ActiveRecord::Migration
  def self.up
    [TaskList, Poll, Asset].each do |data_class|
      data_class.find(:all).each do |data|
        if data.pages.empty?
          puts "%s id %s is missing a page! destroying record." % [data_class, data.id]
          data.destroy
        end
      end
    end
    Wiki.find(:all).each do |wiki|
      if wiki.pages.empty? and wiki.profile.empty?
        puts "wiki id %s does not have a page or a profile! destroying wiki." % wiki.id
        wiki.destroy
      end
    end
  end

  def self.down
    # can't be undone
  end
end

