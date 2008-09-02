module Media::Process
  class Ffmpeg < Processor

    def to_sym; :ffmpeg; end

    def available?
      FFMPEG_COMMAND.any? and File.exists?(FFMPEG_COMMAND)
    end

    def run(options)
      arguments = [FFMPEG_COMMAND, '-y', '-i', options[:in], options[:out]]
      success, output = cmd(*arguments)
      return success
    end

  end
end

