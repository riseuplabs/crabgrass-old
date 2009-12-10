class SvgAsset < Asset

  def update_media_flags
    self.is_image = true
  end

  define_thumbnails(
    :rasterized  => {:ext => 'png', :title => "Rasterized"},
    :small  => {:size => '64x64>',   :ext => 'jpg', :depends => :rasterized, :title => 'Small Thumbnail'},
    :medium => {:size => '200x200>', :ext => 'jpg', :depends => :rasterized, :title => 'Medium Thumbnail'},
    :large  => {:size => '500x500>', :ext => 'jpg', :depends => :rasterized, :title => 'Large Thumbnail'}
  )

end

