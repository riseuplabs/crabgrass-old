module Media::Process
  class Inkscape < Processor

    def to_sym; :inkscape; end

    def available?
      INKSCAPE_COMMAND.any? and File.exists?(INKSCAPE_COMMAND)
    end

    def run(options)
      arguments = [INKSCAPE_COMMAND, '--without-gui', '--export-area-drawing', '--export-area-snap', options[:in], '--export-png', options[:out]]
      success, output = cmd(*arguments)
      return success
    end

=begin
    def dimensions(filename)
      if INKSCAPE_COMMAND.any?
        args = [INKSCAPE_COMMAND, '--query-height', filename]
        success_h, height = cmd(*args)
        args = [INKSCAPE_COMMAND, '--query-width', filename]
        success_w, width = cmd(*args)
        if success_h and success_w
          return [width,height]
        end
      end
    end
=end

  end
end
