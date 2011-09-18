module ShowingBelongsToTrack
  def self.add_to_class_definition
    lambda do
      belongs_to :track
    end
  end
end
