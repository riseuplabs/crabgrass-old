class Asset < ActiveRecord::Base
  @@file_storage = "#{RAILS_ROOT}/assets"
  cattr_accessor :file_storage
  @@public_storage = "#{RAILS_ROOT}/public/assets"
  cattr_accessor :public_storage

  has_attachment :storage => :file_system, :file_system_path => file_storage
  validates_as_attachment

  has_many :pages, :as => :data
  def page; pages.first; end

  def update_access
    if is_public?
      FileUtils.ln_s(full_dirpath, public_dirpath)
    else
      FileUtils.rm_f(public_dirpath) if File.exists?(public_dirpath)
    end
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
