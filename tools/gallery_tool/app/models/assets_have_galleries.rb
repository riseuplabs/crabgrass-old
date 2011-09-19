module AssetsHaveGalleries
  def self.add_to_class_definition
    lambda do
      has_one :showing
      has_one :gallery, :through => :showing
    end
  end
  module InstanceMethods
    def change_source_file(data)
      raise Exception.new(I18n.t(:file_must_be_image_error)) unless
        Asset.mime_type_from_data(data) =~ /image|pdf/
      self.uploaded_data = data
      self.save!
    end
  end
end
