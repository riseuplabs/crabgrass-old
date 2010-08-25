class Crow < ActiveRecord::Base
  def make_sound
    'caw'
  end
  acts_as_extensible
end
