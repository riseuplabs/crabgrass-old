class Asset < ActiveRecord::Base
  @@file_storage = "#{RAILS_ROOT}/assets"
  cattr_accessor :file_storage
  @@public_storage = "#{RAILS_ROOT}/public/assets"
  cattr_accessor :public_storage

  has_attachment :storage => :file_system, :thumbnails => { :thumb => "22x22>", :preview => "128x128>" }
  validates_as_attachment

  def full_filename(thumbnail = nil)
    File.join(@@file_storage, *partitioned_path(thumbnail_name_for(thumbnail)))
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

  def big_icon
    "mime/big/#{icon}"
  end

  def small_icon
    "mime/small/#{icon}"
  end
  
  def icon
    ctype = content_type.to_s.sub(/\/x\-/,'/')  # remove x-
    cgroup = ctype.sub(/\/.*$/,'/')              # everything after /
    iconname = @@mime_to_icon_map[ctype] || @@mime_to_icon_map[cgroup] || @@mime_to_icon_map['default']
    "#{iconname}.png"
  end
    
  @@mime_to_icon_map = {
    'default' => 'default',
    
    'text/' => 'text',
    'text/html' => 'html',
    'application/rtf' => 'rtf',
    
    'application/pdf' => 'pdf',
    'application/bzpdf' => 'pdf',
    'application/gzpdf' => 'pdf',
    'application/postscript' => 'pdf',
    
    'text/spreadsheet' => 'spreadsheet',
    'application/gnumeric' => 'spreadsheet',
    'application/kspread' => 'spreadsheet',
        
    'application/scribus' => 'doc',
    'application/abiword' => 'doc',
    'application/kword' => 'doc',
    
    'application/msword' => 'msword',
    'application/mswrite' => 'msword',
    'application/vnd.ms-powerpoint' => 'mspowerpoint',
    'application/vnd.ms-excel' => 'msexcel',
    'application/vnd.ms-access' => 'msaccess',
    
    'application/executable' => 'binary',
    'application/ms-dos-executable' => 'binary',
    'application/octet-stream' => 'binary',
    
    'application/shellscript' => 'shell',
    'application/ruby' => 'ruby',
        
    'application/vnd.oasis.opendocument.spreadsheet' => 'oo-spreadsheet',    
    'application/vnd.oasis.opendocument.spreadsheet-template' => 'oo-spreadsheet',
    'application/vnd.oasis.opendocument.formula' => 'oo-spreadsheet',
    'application/vnd.oasis.opendocument.chart' => 'oo-spreadsheet',
    'application/vnd.oasis.opendocument.image' => 'oo-graphics',    
    'application/vnd.oasis.opendocument.graphics' => 'oo-graphics',
    'application/vnd.oasis.opendocument.graphics-template' => 'oo-graphics',
    'application/vnd.oasis.opendocument.presentation-template' => 'oo-presentation',
    'application/vnd.oasis.opendocument.presentation' => 'oo-presentation',
    'application/vnd.oasis.opendocument.database' => 'oo-database',
    'application/vnd.oasis.opendocument.text-web' => 'oo-html',
    'application/vnd.oasis.opendocument.text' => 'oo-text',
    'application/vnd.oasis.opendocument.text-template' => 'oo-text',
    'application/vnd.oasis.opendocument.text-master' => 'oo-text',
    
    'packages/' => 'archive',
    'application/zip' => 'archive',
    'application/gzip' => 'archive',
    'application/rar' => 'archive',
    'application/deb' => 'archive',
    'application/tar' => 'archive',
    'application/stuffit' => 'archive',
    'application/compress' => 'archive',
        
    'video/' => 'video',

    'audio/' => 'audio',
    
    'image/' => 'image',
    'image/svg+xml' => 'vector',
    'image/svg+xml-compressed' => 'vector',
    'application/illustrator' => 'vector',
    'image/bzeps' => 'vector',
    'image/eps' => 'vector',
    'image/gzeps' => 'vector',
    
    'application/pgp-encrypted' => 'lock',
    'application/pgp-signature' => 'lock',
    'application/pgp-keys' => 'lock'
  }
  
end
