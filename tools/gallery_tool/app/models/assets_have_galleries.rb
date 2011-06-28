module AssetsHaveGalleries
  def self.add_to_class_definition
    lambda do
      has_many :showings
      has_many :galleries, :through => :showings    
    end
  end

  module InstanceMethods
    def url_from_gallery(gallery_id)
      path('/gallery-assets/', gallery_id, self.id, url_escape(filename))
    end
  end
end
