
#
# PNG files have their own asset type because, unlike other images
# we probably want the thumbnails to be PNGs.
#

class PngAsset < Asset

  def update_media_flags
    self.is_image = true
  end

  define_thumbnails(
    :small  => {:size => '64x64>',   :ext => 'png', :title => 'Small Thumbnail'},
    :medium => {:size => '200x200>', :ext => 'png', :title => 'Medium Thumbnail'},
    :large  => {:size => '500x500>', :ext => 'png', :title => 'Large Thumbnail'}
  )

end

