hostport = url_for(:controller => 'account', :only_path => false).gsub(/\/$/, '')
xml.instruct!
xml.rss :version => '2.0',
  'xmlns:media' => 'http://search.yahoo.com/mrss/',
  'xmlns:content' => 'http://purl.org/rss/1.0/modules/content/' do
  xml.channel do
    if @group
      # this is arguably an abuse of gibberish, but it works
      xml.title :media_for_group.t % [@type_text.t, @group.full_name]
      xml.link hostport + "/" + @group.name
      xml.description :media_for_group.t % [@type_text.t, @group.full_name]
    else
      xml.title :media_without_group.t % @type_text.t
      xml.link hostport + "/"
      xml.description :media_without_group.t % @type_text.t
    end
    if @objects.size > 0
      xml.pubDate @objects[0].updated_at.to_s(:rfc822)
    end
    xml.generator "crabgrass"
    xml.docs "http://blogs.law.harvard.edu/tech/rss"
    @objects.each do |object|
      xml.item do
        xml.title object.page.title
        xml.description object.page.summary
        xml.author "nobody@example.com (#{object.page.updated_by.login})"
        xml.link hostport + page_url(object.page)
        xml << render(:partial => @type.to_s.underscore, :locals => {:hostport => hostport, :object => object})
      end
    end
  end
end