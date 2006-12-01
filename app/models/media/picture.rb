require 'RMagick'

class Picture < ActiveRecord::Base 
  validates_format_of :content_type, :with => /^image/,
      :message => "--- you can only upload pictures"
  
  def picture=(picture_field)
    unless picture_field.length > 0
      errors.add "No photo selected for upload" 
      return
    end
    
    self.name = base_part_of(picture_field.original_filename)
    self.content_type = picture_field.content_type.chomp
    self.data = picture_field.read 
    img = Magick::Image.read_inline(
      Base64.encode64(self.data)
    ).first
            
    #img = Magick::Image.from_blob(self.data)
    thumb = img.scale(48, 48)
    self.thumb = thumb.to_blob
  end
  
  COMMON_EXTENSIONS = {
      'image/jpeg' => 'jpg',
      'image/gif'  => 'gif',
      'image/png'  => 'png',
      'image/x-icon' => 'ico'
    }                        

  def full_name
    ext = COMMON_EXTENSIONS[self.content_type]
    name = self.id
    name = "#{name}.#{ext}" if ext
    return name
  end
  
  def base_part_of(file_name)
    name = File.basename(file_name)
    name.gsub(/[^\w._-]/, '')
  end
end
