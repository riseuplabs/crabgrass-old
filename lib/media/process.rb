module Media
  module Process
    
    # 
    # a note on processing: Chain#run() is not smart about figuring out what processors to run.
    # very simply, it runs the processor it can at a particular step and hopes that there will be
    # a processor down the road that it can pass on its output to.
    #
    # So, care must be taken to ensure that the output types of a processor must
    # either be readable by another processor or will be the ultimate target content type.
    #

    PRIORITY = [:open_office, :graphic_magick, :ffmpeg].freeze

    ## see `ffmpeg -formats`
 
    CONTENT_TYPES_CONSUMED_BY = {
      :open_office => %w(
        text/plain text/html text/richtext application/rtf
        text/csv text/comma-separated-values
        application/msword application/mswrite application/powerpoint
        application/excel application/access application/vnd.ms-msword
        application/vnd.ms-mswrite application/vnd.ms-powerpoint
        application/vnd.ms-excel application/vnd.ms-access
        application/msword-template application/excel-template
        application/powerpoint-template
        application/vnd.oasis.opendocument.spreadsheet
        application/vnd.oasis.opendocument.formula
        application/vnd.oasis.opendocument.chart
        application/vnd.oasis.opendocument.image
        application/vnd.oasis.opendocument.graphics
        application/vnd.oasis.opendocument.presentation
        application/vnd.oasis.opendocument.text-web
        application/vnd.oasis.opendocument.text
        application/vnd.oasis.opendocument.text-template
        application/vnd.oasis.opendocument.text-master
        application/vnd.oasis.opendocument.presentation-template
        application/vnd.oasis.opendocument.graphics-template
        application/vnd.oasis.opendocument.spreadsheet-template
      ),
      :graphic_magick => %w(application/pdf application/bzpdf application/gzpdf
        application/postscript application/xpdf image/jpeg image/pjpeg image/gif
        image/png image/x-png image/jpg image/tiff),
      :ffmpeg => %w(audio/ogg audio/mpeg)
    }.freeze

    CONTENT_TYPES_PRODUCED_BY = {
      :open_office => %w(application/pdf) + CONTENT_TYPES_CONSUMED_BY[:open_office],
      :graphic_magick => %w(application/pdf image/jpeg image/pjpeg
        image/gif image/png image/jpg image/tiff),
      :ffmpeg => %w(audio/ogg audio/mpeg)
    }.freeze

    # a hash of previewable mime/types (eg 'image/png' => true)
    CONSUMABLES = CONTENT_TYPES_CONSUMED_BY.values.flatten.inject({}){|hsh,i|hsh[i]=true;hsh}.freeze

    # a hash of producable mime/types (eg 'image/png' => true)
    PRODUCIBLES = CONTENT_TYPES_PRODUCED_BY.values.flatten.inject({}){|hsh,i|hsh[i]=true;hsh}.freeze

    def self.may_consume?(content_type)
      CONSUMABLES[simple(content_type)]
    end
    def self.may_consume!(content_type)
      raise "I don't know how to consume mime type'%s'" % content_type unless may_consume?(content_type)
    end

    def self.may_produce?(content_type)
      PRODUCIBLES[simple(content_type)]
    end
    def self.may_produce!(content_type)
      raise "I don't know how to produce mime type '%s'" % content_type unless may_produce?(content_type)
    end

    # given 'application/msword', returns object of type Media::Processors::OpenOffice
    def self.get_processor_for(content_type)
      content_type = simple(content_type)
      PRIORITY.each do |processor|
        if CONTENT_TYPES_CONSUMED_BY[processor].include?(content_type)
          processor = self.new_processor(processor) 
          if processor.available?
            return processor
          else
            processor.report_unavailable
            return nil
          end
        end
      end
      return nil
    end

    def self.new_processor(processor)
      Media::Process.const_get(processor.to_s.classify).new()
    end

    def self.has_dimensions?(content_type)
      CONTENT_TYPES_CONSUMED_BY[:graphic_magick].include? simple(content_type)
    end

    def self.dimensions(file)
      Media::Process::GraphicMagick.new.dimensions(file)
    end

    def self.simple(mime_type)
      mime_type.gsub(/\/x\-/,'/') if mime_type # remove x-
    end

  end
end

require 'media/process/base'
require 'media/process/chain'
require 'media/process/processor'
require 'media/process/graphic_magick'
require 'media/process/open_office'

