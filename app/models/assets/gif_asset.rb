
#
# GIF files have their own asset type because, unlike other images,
# we want thumbnails in a format that will preserve transparency. 
#

class GifAsset < Asset

  define_thumbnails(
    :small =>  {:size => '64x64>',   :ext => 'png'},
    :medium => {:size => '200x200>', :ext => 'png'},
    :large =>  {:size => '500x500>', :ext => 'png'}
  )

end

