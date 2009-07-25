class ExternalVideoPage < Page
  include PageExtension::RssData

  #def icon
  #  'page_video'
  #end

  alias_method(:external_video, :data)
  alias_method(:external_video=, :data=)

  def cover
    external_video.thumbnail_url
  end
end
