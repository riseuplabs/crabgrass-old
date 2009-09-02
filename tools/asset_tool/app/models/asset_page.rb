class AssetPage < Page
  include PageExtension::RssData

  before_save :set_cover

  def supports_attachments
    false
  end

  def icon
    return asset.small_icon if asset
    return 'page_package'
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
  def body_terms
    return "" unless self.asset and self.asset.is_a? DocAsset and self.asset.thumbnail(:txt)

    thumbnail = self.asset.thumbnail(:txt)
    thumbnail.generate unless File.exists?(thumbnail.private_filename)
    File.open(thumbnail.private_filename).readlines rescue ""
  end

  # called by Page#update_page_terms
  def custom_page_terms(terms)
    asset = self.data
    if asset
      if asset.new_record?
        asset.page_terms = terms
      elsif asset.page_terms_id != terms.id
        asset.page_terms_id = terms.id
        asset.save_without_revision!
      end
    end
  end

  def set_cover
    self.cover = self.data if self.data.is_a?(ImageAsset)
  end
end

