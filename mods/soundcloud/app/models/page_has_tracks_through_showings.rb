module PageHasTracksThroughShowings
  def self.add_to_class_definition
    lambda do
      has_many :tracks, :through => :showings
    end
  end
end
