class ExternalVideoPage < Page
  include PageExtension::RssData

  alias_method(:external_video, :data)
  alias_method(:external_video=, :data=)

  def external_cover_url
    external_video.thumbnail_url if external_video
  end
end
