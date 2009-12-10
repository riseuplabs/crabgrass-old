# this is included by selected page types which wish to have custom RSS metadata
# appear in feeds.
module PageExtension::RssData
  def self.included(base)
    # this uses a closure and this is slightly magical, but it shows us that
    # ruby is, as they say, tres dynamique.

    partial_name = base.to_s.underscore + "/rss"
    base.send(:define_method, :rss_data_partial) { partial_name }
  end
end