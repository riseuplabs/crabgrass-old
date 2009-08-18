class ExternalVideoPage < Page
  include PageExtension::RssData

  alias_method(:external_video, :data)
  alias_method(:external_video=, :data=)

end
