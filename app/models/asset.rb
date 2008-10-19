=begin

Assets use a lot of classes to manage a particular uploaded file:

  Asset          -- main asset class.
  ImageAsset     -- a subclass of Asset using STI, for example.
  Asset::Version -- all the past and present versions of the main asset.
  Thumbnail      -- a processed representation of an Asset (usually a small image)

  Every asset has many versions. Each asset, and each version, also 
  have many thumbnails. 

  Additionally, three modules are included by Asset:
    AssetExtension::Upload      -- handles uploading data
    AssetExtension::Storage     -- handles where/how data is stored
    AssetExtension::Thumbnails  -- handles the creation of the thumbnails

  Asset::Versions have the latter two included as well.

  Additional modules used by assets:
    Media::MimeType -- where all the mime magicky stuff happens, including
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
  include AssetExtension::Upload
  validates_presence_of :filename

  ##
  ## FINDERS
  ##

  # Use page_terms to find what assets the user has access to. Note that it is
  # necessary to match against both access_ids and tags, since the index only
  # works if both fields are included.
  # FIXME: as far as I can tell page_terms never gets set in the first place,
  # as an asset is always associated with an AssetPage. Polymorphic associations
  # might work in this case, but I'm not sure if that will break anything else.
  #  --niklas
  named_scope :visible_to, lambda { |*args|
    access_filter = PageTerms.access_filter_for(*args)
    { :select => 'assets.*', :joins => :page_terms,
      :conditions => ['MATCH(page_terms.access_ids,page_terms.tags) AGAINST (? IN BOOLEAN MODE)', access_filter]
    }
  }
  
  def has_access! perm, user
    # everything becomes PermissionDenied (e.g. also if self.page is nil)
    self.page.has_access! perm, user rescue raise PermissionDenied
  rescue PermissionDenied
    # if the gallery_tool is disabled Gallery doesn't exist, so we don't check
    # anything at all. otherwise we check if there are any galleries this image
    # is in and the given user has access to.
    unless defined?(Gallery) &&
        self.kind_of?(ImageAsset) &&
        self.galleries.select {|g| user.may?(perm, g) ? g : nil}.any?
      raise PermissionDenied
    end
  end

  named_scope :not_attachment, :conditions => ['is_attachment = ?',false]

  named_scope :most_recent, :order => 'updated_at DESC'

  # one of :image, :audio, :video, :document
  named_scope :media_type, lambda {|type|
    raise TypeError.new unless [:image,:audio,:video,:document].include?(type)
    {:conditions => ["is_#{type} = ?",true]}
  }

  named_scope :exclude_ids, lambda {|ids|
    if ids.any? and ids.is_a? Array
      {:conditions => ['assets.id NOT IN (?)', ids]}
    else
      {}
    end
  }

       
  ##
  ## METHODS COMMON TO ASSET AND ASSET::VERSION
  ## 

  acts_as_versioned do 
    def self.included(base)
      base.send :include, AssetExtension::Storage
      base.send :include, AssetExtension::Thumbnails
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

    def format_description
      Media::MimeType.description_from_mime_type(content_type)
    end
  end
  self.non_versioned_columns << 'page_terms_id' << 'is_attachment' <<
     'is_image' << 'is_audio' << 'is_video' << 'is_document'

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
  def page()
    page_id ? parent_page : pages.first
  end

  belongs_to :page_terms

  # some asset subclasses (like AudioAsset) will display using flash
  # they should override this method to say which partial will render this code
  def embedding_partial
    nil
  end

  before_save :update_is_attachment
  def update_is_attachment
    if page_id_changed?
      self.is_attachment = true if page_id
      self.page_terms = (page.page_terms if page_id)
    end
  end
  
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

  # Auto-determine the appropriate Asset class from the file_data, and calls
  # create on that class.
  # eg. Asset.make(attributes) ---> ImageAsset.create(attributes)
  #     if attributes contains an image file.
  def self.make(attributes = nil)
    asset_class = Asset.class_for_mime_type( mime_type_from_data(attributes[:uploaded_data]) )
    asset_class.create(attributes)
  end

  # like make(), but builds the asset in memory and does not save it.
  def self.build(attributes = nil)
    asset_class = Asset.class_for_mime_type( mime_type_from_data(attributes[:uploaded_data]) )
    asset_class.new(attributes)
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
    if mime =~ /^application/
      mime = Media::MimeType.mime_type_from_extension(file_data.original_filename)
    end
    return mime
  end

  before_create :set_default_type
  def set_default_type
    self.type ||= 'Asset'  # make Asset the default type so Asset::Version.versioned_type will be accurate.
  end

  ##
  ## MEDIA TYPES
  ##

  # Converts the boolean media flags to a list of integers.
  # This is used for sphinx indexing.
  def media_flag_enums
    ret = []
    ret << MEDIA_TYPE[:audio] if is_audio?
    ret << MEDIA_TYPE[:video] if is_video?
    ret << MEDIA_TYPE[:image] if is_image?
    ret << MEDIA_TYPE[:document] if is_document?
    ret.join ' '
  end

  before_save :reset_media_flags
  def reset_media_flags
    if content_type_changed? 
      is_audio = false
      is_video = false
      is_image = false
      is_document = false
      update_media_flags()
    end
  end

  # to be overridden by subclasses
  def update_media_flags() end
  
  
  after_save :update_galleries
  # update galleries after an image was saved which has galleries.
  # the updated_at column of galleries needs to be up to date to allow the
  # download_gallery action to find out if it's cached zips are up to date.
  def update_galleries
    if galleries.any?
      galleries.each { |g| g.save }
    end
  end

  # returns either :landscape or :portrait, depending on the format of the 
  # image.
  def image_format
    raise TypeError unless self.resond_to?(:width) && self.respond_to?(:height)
    self.width > self.height ? :landscape : :portrait
  end
end
