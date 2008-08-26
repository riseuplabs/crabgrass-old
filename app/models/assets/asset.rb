=begin

Assets use a lot of classes to manage a particular uploaded file:

  Asset          -- main asset class.
  ImageAsset     -- a subclass of Asset using STI, for example.
  Asset::Version -- all the past and present versions of the main asset.
  Thumbnail      -- a processed representation of an Asset (usually a small image)

  Every asset has many versions. Each asset, and each version, also 
  have many thumbnails. 

  Additionally, three modules are included by Asset:
    Media::Attachable      -- handles uploading data
    Media::AssetStorage   -- handles where/how data is stored
    Media::HasThumbnails  -- handles the creation of the thumbnails

  Asset::Versions have the latter two included as well.

  Additional modules used by assets:
    Media::MimeType    -- where all the mime magicky stuff happens, including
                          determining which Asset subclass to create.
    Media::Process  -- processors for creating thumbnails.

TODO:

  * Image assets that are smaller than the thumbnails should not get thumbnails,
    or should only get one thumbnail if the format differs. It is a waste of space
    to keep four copies of the same image! (albeit, a very tiny image)

=end

class Asset < ActiveRecord::Base

  # Polymorph does not seem to be working with subclasses of Asset. For parent_type,
  # it always picks "Asset". So, we hardcode what the query should be:
  POLYMORPH_AS_PARENT = 'SELECT * FROM thumbnails WHERE parent_id = #{self.id} AND parent_type = "#{self.type_as_parent}"'

  # This is included here because Asset may take new attachment file data, but
  # Asset::Version and Thumbnail don't need to.
  include Media::Attachable
  validates_presence_of :filename

  ##
  ## METHODS COMMON TO ASSET AND ASSET::VERSION
  ## 

  acts_as_versioned do 
    def self.included(base)
      base.send :include, Media::AssetStorage
      base.send :include, Media::HasThumbnails
      base.has_many :thumbnails, :class_name => '::Thumbnail', :dependent => :destroy, :finder_sql => POLYMORPH_AS_PARENT
      base.define_thumbnails( {} ) # root Asset class has no thumbnails
    end

    # file extension, with '.'
    def ext; File.extname(filename); end

    # file name without extension
    def basename; File.basename(filename, ext); end

    def big_icon
      "mime/big/#{Media::MimeType.icon_for(content_type)}"
    end

    def small_icon
      "mime/small/#{Media::MimeType.icon_for(content_type)}"
    end
  end

  ##
  ## DEFINE THE CLASS Asset::Version
  ##
    
  # to be overridden in Asset::Version
  def version_path; []; end
  def is_version?; false; end
  def type_as_parent; self.type; end

  versioned_class.class_eval do
    delegate :page, :public?, :to => :asset

    # all our paths will have version info inserted into them
    def version_path
      ['versions',version.to_s]
    end

    # our path id will be the id of the main asset
    def path_id
      asset.path_id if asset
    end

    # this object is a version, not the main asset
    def is_version?; true; end
    
    # delegate call to thumbdefs to our original Asset subclass. 
    # eg: Asset::Version#thumbdefs --> ImageAsset.thumbdefs
    def thumbdefs
      versioned_type.constantize.class_thumbdefs if versioned_type
    end

    def type_as_parent
      'Asset::Version'
    end

    # for this version, hard link the files from the main asset
    after_create :clone_files_from_asset, :clone_thumbnails_from_asset
    def clone_files_from_asset
      clone_files_from(asset); true
    end
    def clone_thumbnails_from_asset
      clone_thumbnails_from(asset); true
    end

    # fixes warning: toplevel constant Asset referenced by Asset::Asset
    Asset = ::Asset
  end

  ##
  ## RELATIONSHIP TO PAGES
  ##

  # an asset might have two different types of associations to a page. it could
  # be the data of page (1), or it could be an attachment of the page (2).
  has_many :pages, :as => :data                                             # (1)
  belongs_to :parent_page, :foreign_key => 'page_id', :class_name => 'Page' # (2)
  def page(); pages.first || parent_page; end

  ##
  ## ACCESS
  ##
  
  def update_access
    public? ? add_symlink : remove_symlink
  end

  def public?
    page.nil? or page.public?
  end
  
  ##
  ## ASSET CREATION
  ##

  # auto-determine the appropriate Asset class from the file_data.
  # eg. Asset.make(attributes) ---> ImageAsset.create(attributes)
  #     if attributes contains an image file.
  def self.make(attributes = nil)
     asset_class = Asset.class_for_mime_type( mime_type_from_data(attributes[:uploaded_data]) )
     asset_class.create(attributes)
  end

  # eg: 'image/jpg' --> ImageAsset
  def self.class_for_mime_type(mime)
    if mime
      Media::MimeType.asset_class_from_mime_type(mime).constantize
    else
      Asset
    end
  end
  def self.mime_type_from_data(file_data)
    return nil unless file_data and file_data.any?
    mime = file_data.content_type
    if mime == 'application/octet-stream'
      mime = Media::MimeType.mime_type_from_extension(file_data.original_filename)
    end
    return mime
  end

  before_create :set_default_type
  def set_default_type
    self.type ||= 'Asset'  # make Asset the default type so Asset::Version.versioned_type will be accurate.
  end

end
