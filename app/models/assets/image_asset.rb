class ImageAsset < Asset

  define_thumbnails(
    :small =>  {:size => '64x64>',   :ext => 'jpg'}, 
    :medium => {:size => '200x200>', :ext => 'jpg'}, 
    :large =>  {:size => '500x500>', :ext => 'jpg'}  
  )

end

