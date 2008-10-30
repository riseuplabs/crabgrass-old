xml.content :encoded do
  xml.cdata! object.build_embed
end
xml.media :content, :medium => 'video' do
  xml.media :player, :url => hostport + page_url(object.page)
  xml.media :thumbnail, :url => object.thumbnail_url if object.thumbnail_url
end
xml.guid 'tag:riseup.net,2008/crabgrass-video/' + Digest::SHA1.hexdigest("#{object.id.to_s}--#{object.media_key}"), :isPermaLink => false
