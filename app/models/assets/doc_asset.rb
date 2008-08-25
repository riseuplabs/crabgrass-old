=begin

An asset class for OpenDocument and Office files. 

What files become DocAssets? This is set by lib/media/mime_type.rb

What doc files may generate thumbnails? This is set by lib/media/processors.rb

=end

class DocAsset < Asset

  define_thumbnails(
    :txt   => {:ext => 'txt'},
    :pdf    => {:ext => 'pdf'}, 
    :small  => {:size => '64x64>',   :ext => 'jpg', :depends => :pdf}, 
    :medium => {:size => '200x200>', :ext => 'jpg', :depends => :pdf}, 
    :large  => {:size => '500x500>', :ext => 'jpg', :depends => :pdf}  
  )

end

