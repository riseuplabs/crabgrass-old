#
# For MS Word and OO Text documents.
#

class TextAsset < Asset

  def update_media_flags
    self.is_document = true
  end

  define_thumbnails(
    :odt    => {:ext => 'odt', :proxy => true},
    :txt    => {:ext => 'txt', :depends => :odt},
    :pdf    => {:ext => 'pdf', :depends => :odt},
    :small  => {:size => '64x64>',   :ext => 'jpg', :depends => :pdf, :title => 'Small Thumbnail'},
    :medium => {:size => '200x200>', :ext => 'jpg', :depends => :pdf, :title => 'Medium Thumbnail'},
    :large  => {:size => '500x500>', :ext => 'jpg', :depends => :pdf, :title => 'Large Thumbnail'}
  )

end

