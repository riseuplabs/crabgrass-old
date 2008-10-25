class ExternalVideoPage < Page
  def icon
    'video.png'
  end
  
  alias_method(:external_video, :data)
  alias_method(:external_video=, :data=)
end