#
# A simple class used to store banner style information for 
# groups and users. 
# 

class Style # < ActiveRecord:Base
  attr_accessor :color, :background_color, :background_image, :background_position, :background_repeat

  def initialize(hsh={})
    hsh.each do |key,value| 
      self.send("#{key}=",value)
    end
  end
  
end

