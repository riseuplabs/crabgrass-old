class Asset < ActiveRecord::Base
  @@file_storage = "#{RAILS_ROOT}/assets"
  cattr_accessor :file_storage
  @@public_storage = "#{RAILS_ROOT}/public/assets"
  cattr_accessor :public_storage

  has_attachment :storage => :file_system
  validates_as_attachment

  def full_filename(thumbnail = nil)
    File.join(@@file_storage, *partitioned_path(thumbnail_name_for(thumbnail)))
  end

  def document?
    content_type.to_s =~ /^application\/[msword|pdf]/
  end

  has_many :pages, :as => :data
  def page; pages.first; end

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

  def public_filename
    "/assets/#{id}/#{filename}"
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
end
