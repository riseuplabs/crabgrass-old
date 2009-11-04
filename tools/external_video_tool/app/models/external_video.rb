=begin

create_table "external_videos", :force => true do |t|
  t.string   "media_key"
  t.string   "media_url"
  t.string   "media_thumbnail_url"
  t.text     "media_embed"
  t.integer  "page_terms_id",       :limit => 11
  t.datetime "created_at",                        :null => false
  t.datetime "updated_at",                        :null => false
end

=end

# this is largely taken from the network.greenchange codebase
# http://github.com/sethwalker/greenchange/tree/master/app/models/external_video.rb
#

class ExternalVideo < ActiveRecord::Base
  include PageData
  before_save :update_page_terms

  HEIGHT_RE = /height(="|:)(\d+)/
  WIDTH_RE = /width(="|:)(\d+)/

  SERVICES = [

    { :name => :youtube,
      :token => /youtube/,
      :media_key_pattern => /youtube.com\/v\/([\w-]+)/,
      :default_width =>  '425',
      :default_height =>  '355',
      :thumbnail_template => "http://img.youtube.com/vi/%1$s/default.jpg",
      :template => %Q[<object width="%2$d" height="%3$d"><param name="movie" value="http://www.youtube.com/v/%1$s"></param><param name="wmode" value="transparent"></param><embed src="http://www.youtube.com/v/%1$s" type="application/x-shockwave-flash" wmode="transparent" width="%2$d" height="%3$d"></embed></object>]
    },

    { :name => :google_video,
      :token => /video\.google\.com/,
      :media_key_pattern => /video.google.com\/googleplayer.swf\?docid=([\w-]+)/,
      :default_width =>  '400',
      :default_height =>  '326',
      :template => %Q[<embed id="VideoPlayback" style="width:%2$dpx;height:%3$dpx" allowFullScreen="true" src="http://video.google.com/googleplayer.swf?docid=%1$s&hl=en&fs=true" type="application/x-shockwave-flash"> </embed>]
    },

    { :name => :bliptv,
      :token => /blip\.tv/,
      :media_key_pattern => /blip.tv\/play\/([\w-]+)/,
      :default_width =>  '480',
      :default_height =>  '300',
      :template => %Q[<embed src="http://blip.tv/play/%1$s" type="application/x-shockwave-flash" width="%2$d" height="%3$d" allowscriptaccess="always" allowfullscreen="true"></embed>]
    },

    { :name => :vimeo,
      :token => /vimeo\.com/,
      :media_key_pattern => /vimeo.com\/moogaloop.swf\?clip_id=([\w-]+)/,
      :default_width =>  '400',
      :default_height =>  '225',
      :template => %Q[<object width="%2$d" height="%3$d"> <param name="allowfullscreen" value="true" /> <param name="allowscriptaccess" value="always" /> <param name="movie" value="http://vimeo.com/moogaloop.swf?clip_id=%1$s&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" />  <embed src="http://vimeo.com/moogaloop.swf?clip_id=%1$s&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" type="application/x-shockwave-flash" allowfullscreen="true" allowscriptaccess="always" width="%2$d" height="%3$d"></embed></object><br />]
#      <a href="http://vimeo.com/833101?pg=embed&amp;sec=833101">Cynthia McKinney - Green Party Presidential Candidate - Interviewed on Issues</a> from <a href="http://vimeo.com/craigseeman?pg=embed&amp;sec=833101">Craig Seeman</a> on <a href="http://vimeo.com?pg=embed&amp;sec=833101">Vimeo</a>]
    }
  ]

  before_validation { @service_name = nil }
  validate :supported

  def supported
    errors.add(:media_embed, I18n.t(:video_service_is_not_supported)) unless service
  end

  def service
    @service ||= SERVICES.find { |service| media_embed =~ service[:token] }
  end

  def service_name
    service[:name] if service
  end

  def thumbnail_url
    service[:thumbnail_template] % media_key if media_key and service and service[:thumbnail_template]
  end

  def media_key
    read_attribute(:media_key) || extract_media_key_from_embed
  end

  def extract_media_key_from_embed
    media_embed[service[:media_key_pattern], 1] if service
  end

  def height
    read_attribute(:height) || (media_embed && media_embed[HEIGHT_RE, 2]) || default_height
  end

  def width
    read_attribute(:width) || (media_embed && media_embed[WIDTH_RE, 2]) || default_width
  end

  def default_width
    service[:default_width] if service
  end

  def default_height
    service[:default_height] if service
  end

  def build_embed(crop_width = width, crop_height = height)
    service[:template ] % [media_key, crop_width, crop_height] if service
  end

  def media_embed=(str)
    # @service is a cache that needs to be cleared
    @service = nil
    write_attribute(:media_embed, str)
  end

  def update_page_terms
    self.page_terms = page.page_terms unless page.nil?
  end

  def is_video?
    true
  end

end
