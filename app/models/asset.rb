begin
  require 'mime/types'
rescue LoadError => exc
end

class Asset < ActiveRecord::Base
  
  include Crabgrass::MimeType

  ## associations #####################################

  belongs_to :parent_page, :foreign_key => 'page_id', :class_name => 'Page'
  has_many :pages, :as => :data
  def page
    pages.first || parent_page
  end

  def index
    # TODO: extract a text summary if that makes sense for this document type
  end

  ## versions #########################################
  
  # both this class and the versioned class use attachment_fu
  acts_as_versioned do
    def self.included(klass)
      klass.has_attachment :storage => :file_system, :max_size => 3.megabytes,
        :thumbnails => {:thumb => "22x22>", :preview => "512x512>"}
      klass.validates_as_attachment
    end
  end
  def save_version_on_create_with_thumbnails_excluded
    save_version_on_create_without_thumbnails_excluded unless parent_id
  end
  alias_method_chain :save_version_on_create, :thumbnails_excluded

  # when cloning a model, we need to set the new versions file data
  def clone_versioned_model_with_file_data(orig_model, new_model)
    clone_versioned_model_without_file_data(orig_model, new_model)
    return if orig_model.new_record?
    new_model.temp_data = orig_model.temp_data || (File.read(orig_model.full_filename) if File.exists?(orig_model.full_filename))
  end
  alias_method_chain :clone_versioned_model, :file_data

  def destroy_file_with_versions_directory
    FileUtils.rm_rf(File.join(full_dirpath, 'versions'))
    destroy_file_without_versions_directory
  end
  alias_method_chain :destroy_file, :versions_directory
  
  versioned_class.class_eval do
    delegate :page, :is_public?, :small_icon, :big_icon,
      :icon, :has_thumbnail?, :may_thumbnail?, :to => :asset
    def public_filename(thumbnail = nil)
      "/assets/#{asset.id}/versions/#{version}/#{thumbnail_name_for(thumbnail)}"
    end
    def full_filename(thumbnail = nil)
      version = self.version || parent.version
      File.join(@@file_storage, *partitioned_path('versions', version.to_s, thumbnail_name_for(thumbnail)))
    end
    def attachment_path_id
      asset.attachment_path_id if asset
    end
    def asset_with_parent
      asset_without_parent || parent.asset
    end
    alias_method_chain :asset, :parent
    # fixes warning: toplevel constant Asset referenced by Asset::Asset
    Asset = ::Asset
  end


  ## methods #########################################
  
  @@file_storage = "#{RAILS_ROOT}/assets"
  cattr_accessor :file_storage
  @@public_storage = "#{RAILS_ROOT}/public/assets"
  cattr_accessor :public_storage

  def full_filename(thumbnail = nil)
    File.join(@@file_storage, *partitioned_path(thumbnail_name_for(thumbnail)))
  end

  def update_access
    if is_public?
      FileUtils.ln_s(full_dirpath, public_dirpath) unless File.exists?(public_dirpath)
    else
      remove_symlink
    end
  end

  before_destroy :remove_symlink
  def remove_symlink
    FileUtils.rm_f(public_dirpath) if File.exists?(public_dirpath)
  end
  
  def is_public?
    return true unless page
    return page.public?
  end

  def public_filename(thumbnail = nil)
    "/assets/#{id}/#{thumbnail_name_for(thumbnail)}"
  end

  def public_filepath
    "#{public_storage}/#{id}/#{filename}"
  end

  def public_dirpath
    File.dirname(public_filepath)
  end

  def full_dirpath
    File.dirname(full_filename)
  end

  def extname
    File.extname(filename)
  end
  alias :suffix :extname

  def basename
    File.basename(filename, File.extname(filename))
  end
  
  def big_icon
    "mime/big/#{icon_for(content_type)}"
  end

  def small_icon
    "mime/small/#{icon_for(content_type)}"
  end
    

  ##################################################
  # previews

  ## TODO: test if gm and abiword are installed
  def generate_non_image_thumbnail
    ctype = content_type
    fname = full_filename
    tmps = []

    # try abiword conversion
    if convertable_by?(ctype, :abiword)
      output_pdf = tmp_file_name('preview','pdf')
      tmps << output_pdf
      run_converter(:abiword, fname, output_pdf)
      ctype = 'application/pdf'
      fname = output_pdf
    end

    # try gm conversion
    if convertable_by?(ctype, :gm)
      output_jpg = tmp_file_name('preview','jpg')
      tmps << output_jpg
      run_converter(:gm, fname, output_jpg)
      fname = output_jpg
    end
    
    set_thumbnail_image(fname)
    tmps.each{|f|File.unlink(f)} # remove tmps
  end

  def may_thumbnail?
    image? or convertable_by?(content_type, :any)
  end 

  # returns true if this asset has thumbnails
  # this is unfortunately inefficient, because it requires a database query
  def has_thumbnail?
    may_thumbnail? and thumbnails.any?
  end
  
  # override default uploaded_data= in order to be able to 
  # assign the correct mime-type if we don't pick it up correctly
  # from the browser. 
  def uploaded_data=(file_data)
    return nil if file_data.nil? || file_data.size == 0
    self.content_type = file_data.content_type
    if defined?('MIME::Types') and self.content_type == 'application/octet-stream'
      # ie6 does not accurately report content_type. if the type is generic binary
      # then use the file extension to guess:
      self.content_type = MIME::Types.type_for(file_data.original_filename).first
    end
    self.filename = file_data.original_filename if respond_to?(:filename)
    if file_data.is_a?(StringIO)
      file_data.rewind
      self.temp_data = file_data.read
    else
      self.temp_path = file_data
    end
  end

  protected

  def tmp_file_name(base, ext)
    tmp = Tempfile.new(base + random_tempfile_filename)
    path = tmp.path
    tmp.close!
    return path+'.'+ext
  end

  def set_thumbnail_image(image_tmp_file)
    # attachment_options[:thumbnails] looks like this: {:thumb => "100x100>", :preview => "512x512>"}
    attachment_options[:thumbnails].each do |suffix, size|
      our_create_or_update_thumbnail(image_tmp_file, suffix, *size)
    end
  end

  # Just like the attachment_fu create_or_update_thumbnail, but we have replaced
  # thumbnailable? with may_thumbnail?. If we tried to override thumbnailable, 
  # attachment_fu would try to generate a thumbnail itself. 
  # Also, we are hardcoding the content_type to be jpg.
  def our_create_or_update_thumbnail(temp_file, file_name_suffix, *size)
    may_thumbnail? || raise(ThumbnailError.new("Don't know how to create a thumbnail of content type '%s'" % content_type))
    returning find_or_initialize_thumbnail(file_name_suffix) do |thumb|
      thumb.attributes = {
        :content_type             => "image/jpg",
        :filename                 => thumbnail_name_for(file_name_suffix),
        :temp_path                => temp_file,
        :thumbnail_resize_options => size
      }
      callback_with_args :before_thumbnail_saved, thumb
      thumb.save!
    end
  end

  # normally, all the thumbnails have the same file extension 
  # as the parent asset. So if you have a ".png", the preview will
  # be ".png". we need to break this behavior so that a ".pdf"
  # can have a preview of ".jpg".
  def thumbnail_name_for_with_hardcoded_ext(thumbnail = nil)
#    puts '/----------------------------------------------'
#    puts thumbnail.inspect
#    puts self.inspect
#    puts '\----------------------------------------------'
    return filename if thumbnail.blank?
    if may_thumbnail? and !image?
      # not an image, but we can preview, so hardcode the thumbnail ext.
      basename = filename.gsub /\.\w+$/, ''
      ext = '.jpg'
      "#{basename}_#{thumbnail}#{ext}"      
    else
      # otherwise, proceed as normal
      thumbnail_name_for_without_hardcoded_ext(thumbnail)
    end
  end
  alias_method_chain :thumbnail_name_for, :hardcoded_ext

  ## override default destroy_thumbnails
  def destroy_thumbnails
    if may_thumbnail? && respond_to?(:parent_id) && parent_id.nil?
      self.thumbnails.each { |thumbnail| thumbnail.destroy }
    end
  end

end
