# == Schema Information
# Schema version: 24
#
# Table name: avatars
#
#  id     :integer(11)   not null, primary key
#  data   :binary        
#  public :boolean(1)    
#

class Avatar < ActiveRecord::Base

  acts_as_fleximage do
    image_directory = 'public/avatars'
    preprocess_image do |image|
      image.size = '96x96'
      image.crop = true
    end
  end
    
  def self.pixels(size)
    case size
      when 'tiny';   '12x12'
      when 'xsmall'; '22x22'
      when 'small' ; '32x32'
      when 'medium'; '48x48'
      when 'large' ; '64x64'
      else; '96x96'
    end
  end
  
end
