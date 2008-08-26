begin
  require 'mime/types'
rescue LoadError => exc
  ;# no mime_types gem
end


module Media
  module MimeType

    def self.mime_group(mime_type)
      mime_type.sub(/\/.*$/,'/') if mime_type     # remove everything after /
    end

    def self.simple(mime_type)
      mime_type.to_s.sub(/\/x\-/,'/') if mime_type # remove x-
    end

    def self.lookup(mime_type,field)
      (MIME_TYPES[simple(mime_type)]||[])[field]
    end

#    def self.group_from_mime_type(mime_type)
#      lookup(mime_type,GROUP) || lookup(mime_group(mime_type),GROUP)
#    end

    def self.icon_for(mtype)
      iconname = lookup(mtype,ICON) || lookup(mime_group(mtype),ICON) || lookup('default',ICON)
      "#{iconname}.png"
    end

    def self.asset_class_from_mime_type(mime_type)
      asset_symbol_from_mime_type(mime_type).to_s.classify
    end

    def self.asset_symbol_from_mime_type(mime_type)
      lookup(mime_type,ASSET_CLASS) || lookup(mime_group(mime_type),ASSET_CLASS) || lookup('default',ASSET_CLASS)
    end

    def self.extension_from_mime_type(mime_type)
      lookup(mime_type,EXT)
    end
    
    def self.mime_type_from_extension(ext)
      ext = File.extname(ext).gsub('.','') if ext =~ /\./
      EXTENSIONS[ext] || ((MIME::Types.type_for('.'+ext).first||MIME::Type.new('application/octet-stream')).content_type if defined?(MIME::Types))
    end

    def self.description_from_mime_type(mime_type)
      lookup(mime_type,DESCRIPTION) || lookup(mime_group(mime_type),DESCRIPTION) || lookup('default',DESCRIPTION)
    end
   
    EXT = 0; ICON = 1; ASSET_CLASS = 2; DESCRIPTION = 3;
    MIME_TYPES = {
      # mime_type       => [file_extension, icon, asset_class, description]
      'default'         => [nil,'default',:asset,'Unknown'],
      
      'text/'           => [:txt,:html,:doc_asset, 'Text'],
      'text/html'       => [:html,:html,:doc_asset, 'Webpage'],
      'application/rtf' => [:rtf,:rtf,:doc_asset, 'Rich Text'],
      'text/rtf'        => [:rtf,:rtf,:doc_asset, 'Rich Text'],
      'text/sgml'       => [:sgml,:xml,nil],
      'text/xml'        => [:xml,:xml,nil],
      'text/csv'        => [:csv,:spreadsheet,:doc_asset, 'Comma Separated Values'],
      'text/comma-separated-values' => [:csv,:spreadsheet,:doc_asset, 'Comma Separated Values'],

      'application/pdf'   => [:pdf,:pdf,:image_asset, 'Portable Document Format'],
      'application/bzpdf' => [:pdf,:pdf,:image_asset, 'Portable Document Format'],
      'application/gzpdf' => [:pdf,:pdf,:image_asset, 'Portable Document Format'],
      'application/postscript' => [:ps,:pdf,:image_asset],
      
      'text/spreadsheet'     => [:txt,:spreadsheet,:doc_asset],
      'application/gnumeric' => [:gnumeric,:spreadsheet,:doc_asset],
      'application/kspread'  => [:kspread,:spreadsheet,:doc_asset],
          
      'application/scribus' => [:scribus,:doc,nil],
      'application/abiword' => [:abw,:doc,:doc_asset],
      'application/kword'   => [:kwd,:doc,:doc_asset],
      

      'application/msword'     => [:doc,:msword,:text_asset,'MS Word'],
      'application/mswrite'    => [:doc,:msword,:text_asset,'MS Write'],
      'application/powerpoint' => [:ppt,:mspowerpoint,:doc_asset,'MS Powerpoint'],
      'application/excel'      => [:xls,:msexcel,:spreadsheet_asset,'MS Excel'],
      'application/access'     => [nil, :msaccess, :doc_asset,'MS Access'],
      'application/vnd.ms-msword'     => [:doc,:msword,:text_asset,'MS Word'],
      'application/vnd.ms-mswrite'    => [:doc,:msword,:text_asset,'MS Write'],
      'application/vnd.ms-powerpoint' => [:ppt,:mspowerpoint,:doc_asset,'MS Powerpoint'],
      'application/vnd.ms-excel'      => [:xls,:msexcel,:spreadsheet_asset,'MS Excel'],
      'application/vnd.ms-access'     => [nil, :msaccess, :doc_asset,'MS Access'],
      'application/msword-template'     => [:doc,:msword,:text_asset,'MS Word Template'],
      'application/excel-template'      => [:xlt,:msexcel,:spreadsheet_asset,'MS Excel Template'],
      'application/powerpoint-template' => [:pot,:mspowerpoint,:doc_asset,'MS Powerpoint Template'],

      'application/executable'        => [nil,:binary,nil],
      'application/ms-dos-executable' => [nil,:binary,nil],
      'application/octet-stream'      => [nil,:binary,nil],
      
      'application/shellscript' => [:sh,:shell,nil],
      'application/ruby'        => [:rb,:ruby,nil],
          
      'application/vnd.oasis.opendocument.spreadsheet'  => [:ods,:oo_spreadsheet,:spreadsheet_asset, 'OpenDocument Spreadsheet'],
      'application/vnd.oasis.opendocument.formula'      => [nil,:oo_spreadsheet,:spreadsheet_asset],
      'application/vnd.oasis.opendocument.chart'        => [nil,:oo_spreadsheet,:spreadsheet_asset],
      'application/vnd.oasis.opendocument.image'        => [nil,:oo_graphics, :doc_asset],
      'application/vnd.oasis.opendocument.graphics'     => [:odg,:oo_graphics, :doc_asset],
      'application/vnd.oasis.opendocument.presentation' => [:odp,:oo_presentation,:doc_asset, 'OpenDocument Presentation'],
      'application/vnd.oasis.opendocument.database'     => [:odf,:oo_database,:doc_asset],
      'application/vnd.oasis.opendocument.text-web'     => [:html,:oo_html,:doc_asset],
      'application/vnd.oasis.opendocument.text'         => [:odt,:oo_text,:doc_asset, 'OpenDocument Text'],
      'application/vnd.oasis.opendocument.text-master'  => [:odm,:oo_text,:doc_asset],

      'application/vnd.oasis.opendocument.presentation-template' => [:otp,:oo_presentation,:doc_asset],
      'application/vnd.oasis.opendocument.graphics-template'     => [:otg,:oo_graphics,:doc_asset],
      'application/vnd.oasis.opendocument.spreadsheet-template'  => [:ots,:oo_spreadsheet,:spreadsheet_asset],
      'application/vnd.oasis.opendocument.text-template'         => [:ott,:oo_text,:doc_asset],

      'packages/'        => [nil,:archive,nil],
      'multipart/zip'    => [:zip,:archive,nil],
      'multipart/gzip'   => [:gzip,:archive,nil],
      'multipart/tar'    => [:tar,:archive,nil],
      'application/zip'  => [:gzip,:archive,nil],
      'application/gzip' => [:gzip,:archive,nil],
      'application/rar'  => [:rar,:archive,nil],
      'application/deb'  => [:deb,:archive,nil],
      'application/tar'  => [:tar,:archive,nil],
      'application/stuffit'        => [:sit,:archive,nil],
      'application/compress'       => [nil,:archive,nil],
      'application/zip-compressed' => [:zip,:archive,nil],

      'video/' => [nil,:video,nil],

      'audio/' => [nil,:audio,nil],
      
      'image/'                   => [nil,:image,:image_asset],
      'image/jpeg'               => [:jpg,:image,:image_asset],
      'image/png'                => [:png,:image,:png_asset],
      'image/gif'                => [:png,:image,:gif_asset],

      'image/svg+xml'            => [:svg,:vector,:image_asset],
      'image/svg+xml-compressed' => [:svg,:vector,:image_asset],
      'application/illustrator'  => [:ai,:vector,:image_asset],
      'image/bzeps'              => [:bzeps,:vector,:image_asset],
      'image/eps'                => [:eps,:vector,:image_asset],
      'image/gzeps'              => [:gzeps,:vector,:image_asset],
      
      'application/pgp-encrypted' => [nil,:lock,nil],
      'application/pgp-signature' => [nil,:lock,nil],
      'application/pgp-keys'      => [nil,:lock,nil]
    }.freeze
   
    # override result of MIME::Types
    # useful for when MIME::Types fails or is ambiguous
    EXTENSIONS = {
      'jpg' => 'image/jpeg',
      'png' => 'image/png',
      'txt' => 'text/plain',
      'flv' => 'video/flv',
      'pdf' => 'application/pdf',
      'odt' => 'application/vnd.oasis.opendocument.text',
      'ods' => 'application/vnd.oasis.opendocument.spreadsheet',
      'odp' => 'application/vnd.oasis.opendocument.presentation'
    }.freeze

   
  end
end
