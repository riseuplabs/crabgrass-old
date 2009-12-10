class SpreadsheetAsset < Asset

  def update_media_flags
    self.is_document = true
  end

  define_thumbnails(
    :ods    => {:ext => 'ods', :proxy => true},
    :csv    => {:ext => 'csv', :depends => :ods},
    :pdf    => {:ext => 'pdf', :depends => :ods},
    :small  => {:size => '64x64>',   :ext => 'jpg', :depends => :pdf, :title => 'Small Thumbnail'},
    :medium => {:size => '200x200>', :ext => 'jpg', :depends => :pdf, :title => 'Medium Thumbnail'},
    :large  => {:size => '500x500>', :ext => 'jpg', :depends => :pdf, :title => 'Large Thumbnail'}
  )

end

