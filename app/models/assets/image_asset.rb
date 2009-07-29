class ImageAsset < Asset

  def update_media_flags
    self.is_image = true
  end

  define_thumbnails(
    :small  => {:size => '64x64>',   :ext => 'jpg', :title => 'Small Thumbnail'},
    :medium => {:size => '200x200>', :ext => 'jpg', :title => 'Medium Thumbnail'},
    :large  => {:size => '500x500>', :ext => 'jpg', :title => 'Large Thumbnail'}
  )

end

