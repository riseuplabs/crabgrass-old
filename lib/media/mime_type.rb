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
      lookup(mtype,ICON) || lookup(mime_group(mtype),ICON) || lookup('default',ICON)
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
      mimetype = EXTENSIONS[ext]
      if defined?(MIME::Types)
        unless MIME::Types.type_for('.'+ext).empty?
          mimetype ||= MIME::Types.type_for('.'+ext).first.content_type
        end
      end
      mimetype ||= 'application/octet-stream'
      return mimetype
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
      'text/sgml'       => [:sgml,:xml,nil,'XML'],
      'text/xml'        => [:xml,:xml,nil,'XML'],
      'text/csv'        => [:csv,:spreadsheet,:doc_asset, 'Comma Separated Values'],
      'text/comma-separated-values' => [:csv,:spreadsheet,:doc_asset, 'Comma Separated Values'],

      'application/pdf'   => [:pdf,:pdf,:image_asset, 'Portable Document Format'],
      'application/bzpdf' => [:pdf,:pdf,:image_asset, 'Portable Document Format'],
      'application/gzpdf' => [:pdf,:pdf,:image_asset, 'Portable Document Format'],
      'application/postscript' => [:ps,:pdf,:image_asset,'Postscript'],

      'text/spreadsheet'     => [:txt,:spreadsheet,:doc_asset,'Spreadsheet'],
      'application/gnumeric' => [:gnumeric,:spreadsheet,:doc_asset,'Gnumeric'],
      'application/kspread'  => [:kspread,:spreadsheet,:doc_asset,'KSpread'],

      'application/scribus' => [:scribus,:doc,nil,'Scribus'],
      'application/abiword' => [:abw,:doc,:doc_asset,'Abiword'],
      'application/kword'   => [:kwd,:doc,:doc_asset,'KWord'],


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
      'application/msword-template'     => [:dot,:msword,:text_asset,'MS Word Template'],
      'application/excel-template'      => [:xlt,:msexcel,:spreadsheet_asset,'MS Excel Template'],
      'application/powerpoint-template' => [:pot,:mspowerpoint,:doc_asset,'MS Powerpoint Template'],

      'application/vnd.openxmlformats-officedocument.presentationml.presentation' =>
        [:pptx, :mspowerpoint,:doc_asset,'MS Powerpoint'],
      'application/vnd.openxmlformats-officedocument.presentationml.presentation' =>
        [:pptm, :mspowerpoint,:doc_asset,'MS Powerpoint'],
      'application/vnd.openxmlformats-officedocument.presentationml.template' =>
        [:potx,:mspowerpoint,:doc_asset,'MS Powerpoint Template'],

      'application/vnd.openxmlformats-officedocument.wordprocessingml.document' =>
        [:docm,:msword,:text_asset,'MS Word'],
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document' =>
        [:docx,:msword,:text_asset,'MS Word'],
      'application/vnd.openxmlformats-officedocument.wordprocessingml.template' =>
        [:dotx,:msword,:text_asset,'MS Word Template'],

      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' =>
        [:xlsm,:msexcel,:spreadsheet_asset,'MS Excel'],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' =>
        [:xlsx,:msexcel,:spreadsheet_asset,'MS Excel'],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.template' =>
        [:xltx,:msexcel,:spreadsheet_asset,'MS Excel Template'],

      'application/executable'        => [nil,:binary,nil,'Program'],
      'application/ms-dos-executable' => [nil,:binary,nil,'Program'],
      'application/octet-stream'      => [nil,:binary,nil],

      'application/shellscript' => [:sh,:shell,nil,'Script'],
      'application/ruby'        => [:rb,:ruby,nil,'Script'],

      'application/vnd.oasis.opendocument.spreadsheet'  =>
        [:ods,:oo_spreadsheet,:spreadsheet_asset, 'OpenDocument Spreadsheet'],
      'application/vnd.oasis.opendocument.formula'      =>
        [nil,:oo_spreadsheet,:spreadsheet_asset, 'OpenDocument Formula'],
      'application/vnd.oasis.opendocument.chart'        =>
        [nil,:oo_spreadsheet,:spreadsheet_asset, 'OpenDocument Chart'],
      'application/vnd.oasis.opendocument.image'        =>
        [nil,:oo_graphics, :doc_asset, 'OpenDocument Image'],
      'application/vnd.oasis.opendocument.graphics'     =>
        [:odg,:oo_graphics, :doc_asset, 'OpenDocument Graphics'],
      'application/vnd.oasis.opendocument.presentation' =>
        [:odp,:oo_presentation,:doc_asset, 'OpenDocument Presentation'],
      'application/vnd.oasis.opendocument.database'     =>
        [:odf,:oo_database,:doc_asset, 'OpenDocument Database'],
      'application/vnd.oasis.opendocument.text-web'     =>
        [:html,:oo_html,:doc_asset, 'OpenDocument Webpage'],
      'application/vnd.oasis.opendocument.text'         =>
        [:odt,:oo_text,:doc_asset, 'OpenDocument Text'],
      'application/vnd.oasis.opendocument.text-master'  =>
        [:odm,:oo_text,:doc_asset, 'OpenDocument Master'],

      'application/vnd.oasis.opendocument.presentation-template' =>
        [:otp,:oo_presentation,:doc_asset, 'OpenDocument Presentation'],
      'application/vnd.oasis.opendocument.graphics-template'     =>
        [:otg,:oo_graphics,:doc_asset, 'OpenDocument Graphics'],
      'application/vnd.oasis.opendocument.spreadsheet-template'  =>
        [:ots,:oo_spreadsheet,:spreadsheet_asset, 'OpenDocument Spreadsheet'],
      'application/vnd.oasis.opendocument.text-template'         =>
        [:ott,:oo_text,:doc_asset, 'OpenDocument Text'],

      'packages/'        => [nil,:archive,nil,'Archive'],
      'multipart/zip'    => [:zip,:archive,nil,'Archive'],
      'multipart/gzip'   => [:gzip,:archive,nil,'Archive'],
      'multipart/tar'    => [:tar,:archive,nil,'Archive'],
      'application/zip'  => [:gzip,:archive,nil,'Archive'],
      'application/gzip' => [:gzip,:archive,nil,'Archive'],
      'application/rar'  => [:rar,:archive,nil,'Archive'],
      'application/deb'  => [:deb,:archive,nil,'Archive'],
      'application/tar'  => [:tar,:archive,nil,'Archive'],
      'application/stuffit'        => [:sit,:archive,nil,'Archive'],
      'application/compress'       => [nil,:archive,nil,'Archive'],
      'application/zip-compressed' => [:zip,:archive,nil,'Archive'],

      'video/' => [nil,:video,nil,'Video'],

      'audio/' => [nil,:audio,:audio_asset,'Audio'],

      'image/'                   => [nil,:image,:image_asset,'Image'],
      'image/jpeg'               => [:jpg,:image,:image_asset],
      'image/png'                => [:png,:image,:png_asset],
      'image/gif'                => [:png,:image,:gif_asset],

      'image/svg+xml'            => [:svg,:vector,:svg_asset,'Vector Image'],
      'image/svg+xml-compressed' => [:svg,:vector,:svg_asset,'Vector Image'],
      'application/illustrator'  => [:ai,:vector,:image_asset,'Vector Image'],
      'image/bzeps'              => [:bzeps,:vector,:image_asset,'Vector Image'],
      'image/eps'                => [:eps,:vector,:image_asset,'Vector Image'],
      'image/gzeps'              => [:gzeps,:vector,:image_asset,'Vector Image'],

      'application/pgp-encrypted' => [nil,:lock,nil,'Crypt'],
      'application/pgp-signature' => [nil,:lock,nil,'Crypt'],
      'application/pgp-keys'      => [nil,:lock,nil,'Crypt']
    }.freeze

    #
    # This extension mapping is used to force certain mime types.
    # Usually, firefox does pretty good at reporting the correct mime-type,
    # but IE always fails (firefox fails on ogg). So, we use the MIME::Types
    # gem to try to get the correct mime from the extension. Sometimes, however,
    # even this doesn't work. This able will force certain types when
    # MIME::Types fails or is ambiguous
    #
    EXTENSIONS = {
      'jpg' => 'image/jpeg',
      'png' => 'image/png',
      'txt' => 'text/plain',
      'flv' => 'video/flv',
      'ogg' => 'audio/ogg',
      'oga' => 'audio/ogg',
      'ogv' => 'vidoe/ogg',
      'pdf' => 'application/pdf',
      'odt' => 'application/vnd.oasis.opendocument.text',
      'ods' => 'application/vnd.oasis.opendocument.spreadsheet',
      'odp' => 'application/vnd.oasis.opendocument.presentation',
      'svg' => 'image/svg+xml',
      'mod' => 'video/mpeg',

      'pptx' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'pptm' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'potx' => 'application/vnd.openxmlformats-officedocument.presentationml.template',
      'docm' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'dotx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.template',
      'xlsm' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'xltx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.template'
    }.freeze


  end
end
