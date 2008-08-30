
class AssetPage < Page

  def icon
    return asset.small_icon if asset
    return 'package.png' 
  end
    
  after_save :update_access
  def update_access
    asset.update_access if asset
  end

  def asset
    self.data
  end

  def asset=(a)
    self.data = a
  end

  # title is the filename if title hasn't been set
  def title
    self['title'] || (self.data.filename.nameize if self.data && self.data.filename)
  end

  # Return string of Asset text, for the full text search index
  def index_data
    return "" unless self.asset and self.asset.is_a? DocAsset and self.asset.thumbnail(:txt)

    thumbnail = self.asset.thumbnail(:txt)
    thumbnail.generate
    File.open(thumbnail.private_filename).readlines rescue ""
  end

end

