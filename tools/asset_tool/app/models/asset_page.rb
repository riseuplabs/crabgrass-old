
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
end

