extend_model :Crow do
  has_many :feathers
  def feather_color
    'black'
  end
  def make_sound
    'squawk'
  end
end
