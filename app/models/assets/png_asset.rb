
#
# PNG files have their own asset type because, unlike other images
# we probably want the thumbnails to be PNGs.
#

class PngAsset < Asset

  define_thumbnails(
    :small =>  {:size => '64x64>',   :ext => 'png'},
    :medium => {:size => '200x200>', :ext => 'png'},
    :large =>  {:size => '500x500>', :ext => 'png'}
  )

end

