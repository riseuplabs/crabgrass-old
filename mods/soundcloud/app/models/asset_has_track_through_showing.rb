module AssetHasTrackThroughShowing
  def self.add_to_class_definition
    lambda do
      has_one :track, :through => :showing
    end
  end
end
