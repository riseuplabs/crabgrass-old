class CorruptedAsset < Asset

  def is_image
    true
  end

  def public?
    false
  end

  def private_filename
    "#{RAILS_ROOT}/public/images/ui/corrupted/corrupted.png"
  end

  def content_type
    "image/png"
  end

  def filename
    "corrupted.png"
  end

  def height
    200 #512
  end

  def width
    512
  end

  #
  # make this corrupted asset also work for a corrupted thumbnail
  #

  def generate
  end

  define_thumbnails(
    :small  => {:size => '64x64>',   :ext => 'jpg', :title => 'Small Thumbnail'},
    :medium => {:size => '200x200>', :ext => 'jpg', :title => 'Medium Thumbnail'},
    :large  => {:size => '500x500>', :ext => 'jpg', :title => 'Large Thumbnail'}
  )

end

