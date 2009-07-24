require 'ftools'

# abstract superclass of OpenOffice and GraphicMagic processors
# subclasses must define available? and run()

module Media::Process
  class Processor < Base

    @@tempfile_path = File.join(RAILS_ROOT, 'tmp', 'processing')

    # return mime_type if mime_type is one of the output formats the process supports
    def output_to_type?(mime_type)
      CONTENT_TYPES_PRODUCED_BY[self.to_sym].include? mime_type
    end

    def output_types
      CONTENT_TYPES_PRODUCED_BY[self.to_sym]
    end
    def output_type; self.output_types.first; end

    def tmp_filename_for(mime_type)
      FileUtils.mkdir_p(@@tempfile_path)
      @@tempfile_path + "/#{rand 1_000_000_000}." + Media::MimeType.extension_from_mime_type(mime_type).to_s
    end

    def report_unavailable
      # for now, just log the error
      log_error 'media processor %s is unavailable' % self.class
    end

    def run!(options)
      unless run(options)
        raise "failed to run #{self.class} processor with options #{options.inspect}"
      end
    end

  end
end

