class Image < FlexImage::Model
  public :rmagick_image
  
  def size
    "#{rmagick_image.columns}x#{rmagick_image.rows}"
  end
  
  def inspect
    "<Image :id => #{id} ... >"
  end
  
  def color_at(coords)
  	rmagick_image.pixel_color(*size_to_xy(coords))
  end
end