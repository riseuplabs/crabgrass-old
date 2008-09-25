module AssetsHaveGalleries
  def self.add_to_class_definition
    lambda do
      has_many :showings
      has_many :galleries, :through => :showings
    end
  end
end
