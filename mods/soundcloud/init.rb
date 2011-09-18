Dispatcher.to_prepare do
  require 'soundcloud_listener'
end

apply_mixin_to_model(Site, SiteHasOneSoundcloudClient)
apply_mixin_to_model(Showing, ShowingBelongsToTrack)
apply_mixin_to_model(Page, PageHasTracksThroughShowings)
