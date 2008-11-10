class ExternalVideoPage < Page

  #def icon
  #  'page_video'
  #end
  
  alias_method(:external_video, :data)
  alias_method(:external_video=, :data=)
end
