#
# this is an attempt to simulate rmagick using the graphicmagick command line tool.
# it is very minimal so far, but it is good enough for avatars.
#

require "open-uri"
require "stringio"
require "fileutils"

require File.join(File.dirname(__FILE__), '/image_temp_file')

module Magick
  class ImageMagickError < RuntimeError; end

  NorthWestGravity = 1
  NorthGravity     = 2
  NorthEastGravity = 3
  WestGravity      = 4
  CenterGravity    = 5
  EastGravity      = 6
  SouthWestGravity = 7
  SouthGravity     = 8
  SouthEastGravity = 9

  RGBColorspace = 1

  VERSION = '1.2.3'

  class Image
    attr :path
    attr :tempfile
    attr :output
    attr_accessor :img_format
    attr_accessor :columns
    attr_accessor :rows
    attr_accessor :colorspace # ignored
    attr_accessor :density    # ignored

    def self.from_blob(blob, extension=nil)
      tempfile = ImageTempFile.new("minimagick#{extension}")
      begin
        tempfile.binmode
        tempfile.write(blob)
      ensure
        tempfile.close
      end
      return self.new(tempfile.path, tempfile)
    end

    # Use this if you don't want to overwrite the image file
    def self.from_file(image_path)
      File.open(image_path, "rb") do |f|
        self.from_blob(f.read, File.extname(image_path))
      end
    end

    def self.read(image_path)
      from_file(image_path)
    end

    def initialize(input_path, tempfile=nil)
      @path = input_path
      @tempfile = tempfile # ensures that the tempfile will stick around until this image is garbage collected.

      # Ensure that the file is an image
      #run_command("identify", @path)
      update_geometry
    end

    ## 
    ## Instance Methods To Mirror RMagick
    ## only a very very limited set of methods are available.
    ##

    def change_geometry!(cols_x_rows)
      cols, rows = cols_x_rows.split('x')
      yield cols.to_i, rows.to_i, self
    end

    def resize!(cols,rows)
      run_command('mogrify', '-geometry', "#{cols}x#{rows}!", @path)
      update_geometry()
    end

    def crop_resized!(newcols,newrows)
      if self.columns > self.rows
        resize = "x#{newrows}"
      else
        resize = "#{newcols}x"
      end
      run_command('mogrify', '-geometry', resize, '-crop', "#{newcols}x#{newrows}", @path)
      update_geometry()
    end

    def format=(new_format)
      if img_format != new_format
        @tempfile = ImageTempFile.new("minimagick-convert")
        newpath = @tempfile.path + "." + new_format
        run_command('convert', '+profile', '*', @path, newpath)
        @path = newpath
        self.img_format = new_format
      end
    end

    def format
      self.img_format
    end

    def strip!
    end

    ## 
    ## Instance Methods
    ## 


    def update_geometry()
      run_command('identify', '-format', '%m %w %h', @path)
      type, width, height = @output.split /\s/
      self.columns = width.to_i
      self.rows = height.to_i
      self.img_format = type
    end

    # For reference see http://www.imagemagick.org/script/command-line-options.php#format
    def [](value)
      # Why do I go to the trouble of putting in newlines? Because otherwise animated gifs screw everything up
      case value.to_s
      when "format"
        run_command("identify", "-format", format_option("%m"), @path).split("\n")[0]
      when "height"
        run_command("identify", "-format", format_option("%h"), @path).split("\n")[0].to_i
      when "width"
        run_command("identify", "-format", format_option("%w"), @path).split("\n")[0].to_i
      when "original_at"
        # Get the EXIF original capture as a Time object
        Time.local(*self["EXIF:DateTimeOriginal"].split(/:|\s+/)) rescue nil
      when /^EXIF\:/i
        run_command('identify', '-format', "%[#{value}]", @path).strip
      else
        run_command('identify', '-format', value, @path).split("\n")[0].strip
      end
    end

    # This is a 'special' command because it needs to change @path to reflect the new extension
    #def format(format)
    #  run_command("mogrify", "-format", format, @path)
    #  @path = @path.sub(/(\.\w+)?$/, ".#{format}")
    #  
    #  raise "Unable to format to #{format}" unless File.exists?(@path)
    #end

    def format(new_format)
      self.format = new_format
    end

    # Writes the temporary image that we are using for processing to the output path
    def write(output_path)
      FileUtils.copy_file @path, output_path
      run_command "identify", output_path # Verify that we have a good image
    end

    # Give you raw data back
    def to_blob
      File.read @path
    end

    def first
      self
    end


    # If an unknown method is called then it is sent through the morgrify program
    # Look here to find all the commands (http://www.imagemagick.org/script/mogrify.php)
    #def method_missing(symbol, *args)
    #  args.push(@path) # push the path onto the end
    #  run_command("mogrify", "-#{symbol}", *args)
    #  self
    #end

    def resize(newsize)
      run_command("mogrify", "-geometry", newsize, @path)
    end

    # You can use multiple commands together using this method
    def combine_options(&block)
      c = CommandBuilder.new
      block.call c
      run_command("mogrify", *c.args << @path)
    end


    # Outputs a carriage-return delimited format string
    def format_option(format)
      "#{format}\\n"
    end

    def run_command(command, *args)
      args.collect! do |arg|
        arg = arg.to_s
        arg = "'" + arg + "'" unless arg[0] == ?- or arg[0] == ?+ 
        # values quoted because they can contain characters like '>', but don't quote switches
        arg
      end
      @output = `gm #{command} #{args.join(' ')}`

      #puts "-"*80
      #puts "gm #{command} #{args.join(' ')}"
      #puts "-"*80

      if $? != 0
        raise ImageMagickError, "graphicmagick command (gm #{command} #{args.join(' ')}) failed: Error Given #{$?}"
      else
        @output
      end
    end
  end

  class CommandBuilder
    attr :args

    def initialize
      @args = []
    end

    def method_missing(symbol, *args)
      @args << "-#{symbol}"
      @args += args
    end
    
    def +(value)
      @args << "+#{value}"
    end
  end
end
