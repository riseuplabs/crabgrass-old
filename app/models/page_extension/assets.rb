#
# Page relationship to Asset
#
# It is a little confusing, but there are many possible page <> asset
# relationships:
#
# attachments:
#
#   asset belongs to parent_page (this file)
#   page has many assets (this file)
#
# page data (polymorphic):
#
#   page belongs to data (which is really an asset) (page.rb)
#   asset has many pages (as data) (page_data.rb)
#
# gallery:
#
#   page has many assets through showings (gallery tool)
#   asset has many pages through showings (gallery tool)
#
#
module PageExtension::Assets

  def self.included(base)
    base.instance_eval do
      has_many   :assets, :dependent => :destroy
      belongs_to :cover, :class_name => "Asset"

      before_save :update_media_flags
      after_save :update_attachment_access
    end
  end

  public

  # if a page has a cover that's not an Asset record
  # page subclasses should override this method should return its location
  def external_cover_url
    nil
  end

  # Adds an asset as an attachment to this page. The asset may be in the form of
  # a Hash or an Asset, either already created or new_record?()
  #
  # Additionally, this method will work with pages that saved or are new_record?()
  #
  # Available options:
  # - :cover -- if true, make this asset a cover asset
  # - :filename -- if set, rename the asset using this filename
  #
  def add_attachment!(asset, options={})
    if asset.is_a? Hash
      asset = Asset.build(asset.merge(:parent_page => self))
    elsif asset.is_a? Asset
      asset.parent_page = self
    end

    self.assets << asset
    self.cover = asset if options[:cover]
    asset.base_filename = options[:filename] if options[:filename].any?

    unless asset.new_record?
      asset.save!
    end

    unless self.new_record?
      self.assets.reset
      self.save! if self.cover_id_changed?
    end

    return asset
  end

  protected

  ##
  ## CALLBACKS
  ##

  # sets the default media flags for this page. can be overridden by the subclasses.
  def update_media_flags
    if self.data
      self.is_image = self.data.is_image? if self.data.respond_to?('is_image?')
      self.is_audio = self.data.is_audio? if self.data.respond_to?('is_audio?')
      self.is_video = self.data.is_video? if self.data.respond_to?('is_video?')
      self.is_document = self.data.is_document? if self.data.respond_to?('is_document?')
    end
    true
  end

  # update attachment permissions
  def update_attachment_access
    if public_changed?
      assets.each { |asset| asset.update_access }
    end
    true
  end

end
