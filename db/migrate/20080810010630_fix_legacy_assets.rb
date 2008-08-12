class FixLegacyAssets < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.record_timestamps = false

    ### ASSET PAGES

    pages = AssetPage.find :all
    pages.each do |page|
      asset = page.data
      if !asset.instance_of?(Asset)
        puts "skipping #{page.id}"
        next
      else
        puts page.id
      end

      asset.without_revision do
        asset.type = Media::MimeType.asset_class_from_mime_type(asset.content_type)
        asset.save
      end
      page.data_type = asset.type
      page.save

      asset = Asset.find asset.id
      asset.without_revision do
        asset.filename = asset.filename.gsub('_','-')
        asset.save
      end
      asset.versions.each do |v|
        if !File.exists?(v.private_filename)
          v.destroy
          puts 'destroying version %s of asset %s: no file %s' % [v.version, asset.id, v.private_filename]
        else
          v.filename = v.filename.gsub('_','-')
          v.versioned_type = asset.type
          v.save
        end
      end
      asset.create_thumbnail_records
    end

    ### ATTACHMENTS

    assets = Asset.find :all
    assets.each do |asset|
      asset.without_revision do
        newfilename = asset.filename.gsub('_','-')
        if asset.filename != newfilename
          puts 'rename %s --> %s' % [asset.filename, newfilename]
          asset.filename = newfilename
          asset.save
        end
      end
      asset.versions.each do |v|
        if !File.exists?(v.private_filename)
          v.destroy
          puts 'destroying version %s of asset %s: no file %s' % [v.version, asset.id, v.private_filename]
        else
          newfilename = v.filename.gsub('_','-')
          if v.filename != newfilename
            puts 'rename %s --> %s' % [v.filename, newfilename]
            v.filename = newfilename
            v.save
          end
        end
      end
    end

  end

  def self.down
    # nope
  end
end


