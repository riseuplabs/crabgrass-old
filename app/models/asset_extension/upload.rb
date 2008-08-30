begin
  require 'mime/types'
rescue LoadError => exc
  # can't fix messed up IE mime_types without mime_types gem.
end


## can be used to create assets from a script instead of uploaded from a browser:
## asset = Asset.make :uploaded_data => FileData.new('/path/to/file')
class FileData < String
  attr_accessor :size, :original_filename, :content_type
  def initialize(filename)
    super(filename)
    self.size = 1
    self.original_filename = filename
    self.content_type = Media::MimeType.mime_type_from_extension(filename)
  end
end



module AssetExtension
  module Upload

    def self.included(base)

      base.after_validation :process_attachment
      base.after_update :finalize_attachment  #  \  both are needed
      base.after_create :finalize_attachment  #  /

      base.extend(ClassMethods)
      base.instance_eval do
        include InstanceMethods
      end
    end

    module ClassMethods
    end
   
    module InstanceMethods
      def uploaded_data=(file_data)
        return nil if file_data.nil? || file_data.size == 0
        mime_type = Asset.mime_type_from_data(file_data)
        klass = Asset.class_for_mime_type(mime_type)
        @old_files = self.all_filenames || []
        if self.class != klass
           # we are attempting something weird and strange:
           # the new file_data is totally different than our previous file data,
           # so we try to make ourselves quack like the new asset class. 
           self.thumbnails.clear
           self.type = Media::MimeType.asset_class_from_mime_type(mime_type)
           self.thumbdefs = klass.class_thumbdefs
        end
        self.content_type = mime_type
        self.filename_will_change! # just in case nothing is different, force dirty.
        self.filename = file_data.original_filename
        @temp_files = Media::TempFileArray.new(file_data)
      end

      def process_attachment
        if uploaded_data_changed?
          self.size = File.size(@temp_files.path)
          if Media::Process.has_dimensions?(self.content_type)
            self.width, self.height = Media::Process.dimensions(@temp_files.path)
          end
        end
        true
      end

      def finalize_attachment
        return true unless uploaded_data_changed?
        remove_files(*@old_files)
        @old_files.clear
        save_to_storage(@temp_files.path)
        @temp_files.clear
        create_thumbnail_records
        true
      end
      
      def uploaded_data_changed?
        @temp_files.any?
      end

    end

  end
end


