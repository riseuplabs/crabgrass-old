module Crabgrass
  module MimeType

    def icon_for(mtype)
      mtype = mtype.to_s.sub(/\/x\-/,'/')  # remove x-
      mgroup = mtype.sub(/\/.*$/,'/')      # everything after /
      iconname = MAP_MIME_TYPE_TO_ICON[mtype] || MAP_MIME_TYPE_TO_ICON[mgroup] || MAP_MIME_TYPE_TO_ICON['default']
      "#{iconname}.png"
    end

    def convertable_by?(mime_type, command)
      if command == :any
        PREVIEWABLE_CONTENT.include?(mime_type)
      elsif converter_available?(command)
        MIME_PREVIEWABLE_BY[command].include?(mime_type)
      else
        false
      end
    end

    def converter_available?(command)
      PREVIEW_COMMANDS_AVAILABLE[command.to_sym].any?
    end
    
    def run_converter(command, input_file, output_file)
      if command == :abiword
        system(cmd_path(:abiword), input_file, '--to', output_file) 
      elsif command == :gm
        # we pick 512 as a size you probably don't want to make a preview bigger than
        # in order to speed up the processing.
        system(cmd_path(:gm), 'convert', '-geometry', '512x512', '-density', '60', input_file+'[0]', output_file)
      elsif command == :openoffice
        system(cmd_path(:openoffice), input_file, output_file)
      end
    end

    def cmd_path(cmd)
      PREVIEW_COMMANDS_AVAILABLE[cmd]
    end

    PREVIEW_COMMANDS_AVAILABLE = {
      :abiword => (Crabgrass::Config.abiword || `which abiword`.chomp),
      :gm => (Crabgrass::Config.gm || `which gm`.chomp),
      :openoffice => (Crabgrass::Config.openoffice || ("#{RAILS_ROOT}/lib/openoffice_converter.py" if `which python`.any? and `which openoffice`.any?))
    }.freeze

    MIME_PREVIEWABLE_BY = {
      :abiword => %w(text/ text/html text/richtext application/rtf application/msword),
      :gm => %w(application/pdf application/bzpdf application/gzpdf application/postscript application/xpdf),
      :rmagick => %w(image/jpeg image/pjpeg image/gif image/png image/x-png image/jpg)
    }.freeze
    PREVIEWABLE_CONTENT = MIME_PREVIEWABLE_BY.values.flatten.freeze

    MAP_MIME_TYPE_TO_ICON = {
      'default' => 'default',
      
      'text/' => 'text',
      'text/html' => 'html',
      'application/rtf' => 'rtf',
      'text/rtf' => 'rtf',
      'text/comma-separated-values' => 'text', # <- replace with better icon
      'text/csv' => 'text', # <- replace with better icon
      'text/sgml' => 'text', # <- replace with better icon
      'text/xml' => 'text', # <- replace with better icon

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
      'application/powerpoint' => 'mspowerpoint',
      'application/excel' => 'msexcel',
      'application/access' => 'msaccess',
      'application/vnd.ms-msword' => 'msword',
      'application/vnd.ms-mswrite' => 'msword',
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
      'application/zip-compressed' => 'archive',
      'application/gzip' => 'archive',
      'application/rar' => 'archive',
      'application/deb' => 'archive',
      'application/tar' => 'archive',
      'application/stuffit' => 'archive',
      'application/compress' => 'archive',
      'multipart/zip' => 'archive',
      'multipart/gzip' => 'archive',
      'multipart/tar' => 'archive',

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
    }.freeze




  end
end
