

#class Avatar < FlexImage::Model
class Avatar < ActiveRecord::Base
  # limit image size to 96 x 96
  #pre_process_image :size => '96x96', :crop => true
  
  def self.pixels(size)
    case size
      when 'xsmall'; '16x16'
      when 'small' ; '32x32'
      when 'medium'; '48x48'
      when 'large' ; '64x64'
      else; '96x96'
    end
  end
  
end
