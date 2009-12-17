class UpdateSiteDomains < ActiveRecord::Migration
  def self.up
    Site.all.each do |site|
      site.domain.sub!(/^(?:my\.)?(\w*)\.mruyouth/, "my.#{$1}")
      site.save!
    end
  end

  def self.down
    puts "This migration can not be undone. Please revert the changes to"
    puts "sites table by hand where appropriate."
  end
end
