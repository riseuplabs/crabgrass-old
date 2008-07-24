require 'tempfile'
require 'ftools'

Tempfile.class_eval do
  # overwrite so tempfiles use the extension of the basename.  important for rmagick and image science
  def make_tmpname(basename, n)
    ext = nil
    sprintf("%s%d-%d%s", basename.to_s.gsub(/\.\w+$/) { |s| ext = s; '' }, $$, n, ext)
  end
end

module Media
  class TempFileArray
    @@tempfile_path = File.join(RAILS_ROOT, 'tmp', 'tempfiles')
    cattr_accessor :tempfile_path

    ##
    ## CLASS METHODS
    ##

    def self.copy_to_temp_file(file, temp_base_name)
      returning Tempfile.new(temp_base_name, @@tempfile_path) do |tmp|
        tmp.close
        FileUtils.cp file, tmp.path
      end
    end

    # Writes the given data to a new tempfile, returning the closed tempfile.
    def self.write_to_temp_file(data, temp_base_name)
      returning Tempfile.new(temp_base_name, @@tempfile_path) do |tmp|
        tmp.binmode
        tmp.write data
        tmp.close
      end
    end

    ##
    ## INSTANCE METHODS
    ##

    def initialize(file_data)
      @tmps = []
      add(file_data)
    end

    def add(file_data)
      if file_data.is_a?(StringIO)
        file_data.rewind
        @tmps << write_to_temp_file(file_data.read)
      elsif file_data.instance_of?(String)
        @tmps << copy_to_temp_file(file_data)
      else
        @tmps << file_data
      end
    end

    def clear
      @tmps.clear
    end

    def any?
      @tmps.any?
    end

    # Gets the latest temp path from the collection of temp paths.  While working with an attachment,
    # multiple Tempfile objects may be created for various processing purposes (resizing, for example).
    # An array of all the tempfile objects is stored so that the Tempfile instance is held on to until
    # it's not needed anymore.  The collection is cleared after saving the attachment.
    def path
      p = @tmps.last
      p.respond_to?(:path) ? p.path : p.to_s  # might be a string or a tempfile
    end

    # Gets the data from the latest temp file.  This will read the file into memory.
    def data
      File.file?(path) ? File.read(path) : nil
    end

    # Copies the given file to a randomly named Tempfile.
    def copy_to_temp_file(file)
      self.class.copy_to_temp_file file, random_tempfile_filename
    end

    # Writes the given file to a randomly named Tempfile.
    def write_to_temp_file(data)
      self.class.write_to_temp_file data, random_tempfile_filename
    end

    protected

    # Generates a unique filename for a Tempfile.
    def random_tempfile_filename
      "#{rand Time.now.to_i}_tmp_"
    end

  end
end

FileUtils.mkdir_p(Media::TempFileArray.tempfile_path) unless File.exists?(Media::TempFileArray.tempfile_path)

