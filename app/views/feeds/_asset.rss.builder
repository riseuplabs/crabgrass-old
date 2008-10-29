xml.guid 'tag:riseup.net,2008/crabgrass-asset/' + Digest::SHA1.hexdigest("#{object.id.to_s}--#{object.filename}"), :isPermaLink => false
xml.enclosure :url => (hostport + object.url), :length => object.size, :type => object.content_type
instances = [object] + object.thumbnails.select{|i| i.exists?}
case instances.size
when 0
  # shouldn't ever happen
when 1
  xml << render(:partial => 'rss_media_content', :locals => {:instance => instances[0], :asset => object, :hostport => hostport})
else
  xml.media :group do
    instances.each do |instance|
      xml << render(:partial => 'rss_media_content', :locals => {:instance => instance, :asset => object, :hostport => hostport})
    end
  end
end