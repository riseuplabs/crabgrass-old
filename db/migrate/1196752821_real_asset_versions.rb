class RealAssetVersions < ActiveRecord::Migration
  def self.up
    Asset::Version.find(:all, :conditions => "parent_id IS NULL").each do |version|
      filename = if version.asset.version == version.version
                   version.asset.full_filename
                 else
                   version.full_filename
                 end
      next unless File.exists?(filename)
      Asset::Version.attachment_options[:thumbnails].each do |suffix, size|
        version.create_or_update_thumbnail(filename, suffix, *size) if version.thumbnailable?
      end
    end
  end

  def self.down
  end
end
