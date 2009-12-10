=begin

This file is adapted from vendor/plugins/attachment_fu/lib/technoweenie/attachment_fu/backends/file_system_backend.rb

There are two main modifications:

(1) We want to keep two sets of file storage paths: one for private files and
    one for public files. When an asset becomes public, we create a symbolic
    link in the public directory to the file in the private directory.

(2) Assets may be versioned. We keep the versions in a subfolder called 'versions'

Lets suppose you have an asset called 'myfile.jpg' and have defined two thumbnails,
one called :minithumb and one called :bigthumb.

This is what the directory structure will look like:

  RAILS_ROOT/
    assets/
      0000/
        0055/
          myfile.jpg
          myfile_minithumb.jpg
          myfile_bigthumb.jpg
          versions/
            1/
              myfile.jpg
              myfile_minithumb.jpg
              myfile_bigthumb.jpg
    public/
      assets/
        55 --> RAILS_ROOT/assets/0000/0055/

Multiple asset hosts
--------------------

config.action_controller.asset_host = 'assets%d.example.com'

This tells Rails to generate links to the following four hosts: assets0.example.com, assets1.example.com, assets2.example.com, and assets3.example.com.

=end

require 'ftools'
require 'pathname'

module AssetExtension # :nodoc:
  module Storage

    @@private_storage = ASSET_PRIVATE_STORAGE # \ set in environments/*.rb
    @@public_storage  = ASSET_PUBLIC_STORAGE  # /
    @@public_url_path = "/assets"
    mattr_accessor :private_storage, :public_storage, :public_url_path

    def self.included(base) #:nodoc:
      base.before_update :rename_file
      base.after_destroy :destroy_file
    end

    def self.make_required_dirs
      FileUtils.mkdir_p(@@private_storage) unless File.exists?(@@private_storage)
      FileUtils.mkdir_p(@@public_storage) unless File.exists?(@@public_storage)
    end

    ##
    ## ASSET PATHS
    ##

    # what id number is this asset stored under?
    # overridden by thumbnails
    def path_id
      id.to_i
    end

    # with a path_id of 4, returns ['0000','0004']
    def partitioned_path
       ("%08d" % path_id).scan(/..../)
    end

    # make a file or url path out of potentially missing or nested args
    def path(*args)
      args.flatten.compact.join('/')
    end

    # eg RAILS_ROOT/assets/0000/0055/myfile.jpg
    # or RAILS_ROOT/assets/0000/0055/versions/1/myfile.jpg
    def private_filename
      path private_storage, partitioned_path, version_path, filename
    end

    # eg RAILS_ROOT/assets/0000/0055/myfile~small.jpg
    # or RAILS_ROOT/assets/0000/0055/versions/1/myfile~small.jpg
    def private_thumbnail_filename(thumbnail_name)
      path private_storage, partitioned_path, version_path, thumbnail_filename(thumbnail_name)
    end

    # eg RAILS_ROOT/public/assets/55/myfile.jpg
    # or RAILS_ROOT/public/assets/55/versions/1/myfile.jpg
    def public_filename
      path public_storage, path_id, version_path, filename
    end

    # eg RAILS_ROOT/public/assets/55/myfile~small.jpg
    # or RAILS_ROOT/public/assets/55/versions/1/myfile~small.jpg
    def public_thumbnail_filename(thumbnail_name)
      path public_storage, path_id, version_path, thumbnail_filename(thumbnail_name)
    end

    # eg /assets/55/myfile.jpg
    # or /assets/55/versions/1/myfile.jpg
    def url
      path(public_url_path, path_id, version_path, url_escape(filename))
    end

    # eg /assets/55/myfile~small.jpg
    # or /assets/55/versions/1/myfile~small.jpg
    def thumbnail_url(thumbnail_name)
      path(public_url_path, path_id, version_path, url_escape(thumbnail_filename(thumbnail_name)))
    end

    def url_escape(str)
      str.gsub(/[^a-zA-Z0-9_\-.]/n){ sprintf("%%%02X", $&.unpack("C")[0]) }
    end

    # return a list of all the files that are associated with this asset
    # including thumbnails, but not versions. This list is used to remove
    # old files after a new version is uploaded.
    def all_filenames
      files = []
      if filename
        files << private_filename
        thumbdefs.each do |name,thumbdef|
          files << private_thumbnail_filename(thumbdef)
        end
      end
      files
    end


    ##
    ## override attributes
    ##

    # Sets a new filename.
    def filename=(value)
      write_attribute :filename, sanitize_filename(value)
    end

    # Sets a new base filename, without changing the extension
    def base_filename=(value)
      return unless value
      if read_attribute(:filename) and !value.ends_with?(ext)
        value += ext
      end
      write_attribute :filename, sanitize_filename(value)
    end

    # create a hard link between the files for orig_model
    # and the files for self (which are in a versioned directory)
    def clone_files_from(orig_model)
      if is_version? and filename
        hard_link(orig_model.private_filename, self.private_filename)
        thumbdefs.each do |name, thumbdef|
          hard_link(orig_model.private_thumbnail_filename(thumbdef), self.private_thumbnail_filename(thumbdef))
        end
      end
    end

    def hard_link(source, dest)
      FileUtils.mkdir_p(File.dirname(dest))
      if File.exists?(source) and !File.exists?(dest)
        FileUtils.ln(source, dest)
      end
    end

    protected

    ##
    ## file management
    ##

    # Destroys the all files for this asset.
    def destroy_file
      if is_version?
        # just remove version directory
        FileUtils.rm_rf(File.dirname(private_filename)) if File.exists?(File.dirname(private_filename))
#      elsif is_thumbnail?
#        # just remove thumbnail
#        FileUtils.rm(private_filename) if File.exists?(private_filename)
      else
        # remove everything
        remove_symlink
        FileUtils.rm_rf(File.dirname(private_filename)) if File.exists?(File.dirname(private_filename))
      end
    end

    def rename_file
      if filename_changed? and !new_record? and !uploaded_data_changed?
        Dir.chdir( File.dirname(private_filename) ) do
          FileUtils.mv filename_was, filename
        end
      end
    end

    # Saves the file to the file system
    def save_to_storage(temp_path)
      if File.exists?(temp_path)
        FileUtils.mkdir_p(File.dirname(private_filename))
        File.cp(temp_path, private_filename)
        File.chmod(0644, private_filename)
      end
      true
    end

    def current_data
      File.file?(private_filename) ? File.read(private_filename) : nil
    end

    # creates a symlink from the private asset storage to a publicly accessible directory
    def add_symlink
      unless File.exists?(File.dirname(public_filename))
        real_private_path = Pathname.new(private_filename).realpath.dirname
        real_public_path  = Pathname.new(public_storage).realpath
        public_to_private = real_private_path.relative_path_from(real_public_path)
        real_public_path += "#{path_id}"
        #puts "FileUtils.ln_s(#{public_to_private}, #{real_public_path})"
        FileUtils.ln_s(public_to_private, real_public_path)
      end
    end

    # removes symlink from public directory
    def remove_symlink
      if File.exists?(File.dirname(public_filename))
        FileUtils.rm(File.dirname(public_filename))
      end
    end

    ##
    ## Utility
    ##

    # currently unused
    def sanitize_filename(filename)
      return unless filename
      returning filename.strip do |name|
        # NOTE: File.basename doesn't work right with Windows paths on Unix
        # get only the filename, not the whole path
        name.gsub! /^.*(\\|\/)/, ''

        # strip out ' and "
        # name.gsub! /['"]/, ''

        # keep:
        #  alphanumeric characters
        #  hypen
        #  space
        #  period
        #name.gsub! /[^\w\.\ ]+/, '-'

        # don't allow the thumbnail separator
        name.gsub! /#{THUMBNAIL_SEPARATOR}/, ' '

        # remove weird constructions:
        # - trailing or leading hypen
        # - hypen-space or hypen-period
        # - duplicate spaces
        name.gsub! /^\-|\-$|/, ''
        name.gsub! /\-\.|\.\-/, '.'
        name.gsub! /\-\ |\ \-/, ' '
        name.gsub! /\ +/, ' '
      end
    end

    # a utility function to remove a series of files.
    def remove_files(*files)
      files.each do |file|
        File.unlink(file) if file and File.exists?(file)
      end
    end

  end
end
