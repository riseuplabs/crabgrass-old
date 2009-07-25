=begin

A generic document asset: anything that we can create a pdf out of.

See TextdocAsset and SpreadsheetAsset for more specific asset types.

What files become DocAssets? This is set by lib/media/mime_type.rb
What doc files may generate thumbnails? This is set by lib/media/processors.rb

=end

class DocAsset < Asset

  def update_media_flags
    self.is_document = true
  end

  define_thumbnails(
    :pdf    => {:ext => 'pdf'},
    :small  => {:size => '64x64>',   :ext => 'jpg', :title => 'Small Thumbnail'},
    :medium => {:size => '200x200>', :ext => 'jpg', :title => 'Medium Thumbnail'},
    :large  => {:size => '500x500>', :ext => 'jpg', :title => 'Large Thumbnail'}
  )

end

