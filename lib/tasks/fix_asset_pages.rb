# For some time galleries messed up the AssetPage creation for the Assets
# of the uploaded images.
# They created AssetPages where the data_type was not set. So asset.page would
# return nil.
# Then they created Pages for the uploaded images instead of AssetPages.
#
# # This task should turn the remaining Pages into AssetPages:

task :fix_asset_pages_for_galleries => :environment do
  $stdout.puts "Turning Pages into AssetPages."
  pages = Page.find(:all, :conditions => {
              :type => nil,
              :data_type => "Asset",
              :flow => FLOW[:gallery]})
  pages.each do |p|
    p.update_attribute(:type, "AssetPage")
  end
  $stdout.puts "Worked on #{pages.count} pages."
end

task :remove_messed_up_asset_pages => :environment do
  $stdout.puts "Removing Asset Pages from the gallery that do not have a valid data_type."
  removed = Page.destroy_all("data_type IS NULL AND
                         data_id IS NOT NULL AND
                         type = 'AssetPage' AND
                         flow = #{FLOW[:gallery]}")
  $stdout.puts "Removed #{removed.count} pages."
end

