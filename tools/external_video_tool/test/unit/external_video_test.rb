require 'test/unit'
require File.dirname(__FILE__) + '/../../../../test/test_helper'

class ExternalVideoTest < Test::Unit::TestCase
  def test_invalid
    vid = ExternalVideo.new(:media_embed => '<object>my object</object>')
    assert !vid.valid?
  end

  def test_youtube
    bayern = ExternalVideo.new(:media_embed => '<objectINVALIDHTML width="425" height="344"> TRA LA LA EXTRA TEXT <param name="movie" value="http://www.youtube.com/v/G3KPBRajN10&hl=en&fs=1"></param><param name="allowFullScreen" value="true"></param><embed src="http://www.youtube.com/v/G3KPBRajN10&hl=en&fs=1" type="application/x-shockwave-flash" allowfullscreen="true" width="425" height="344"></embed></object>')
    assert bayern.valid?
    assert_equal :youtube, bayern.service_name
    assert_equal "G3KPBRajN10", bayern.media_key
    assert_equal '<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/G3KPBRajN10"></param><param name="wmode" value="transparent"></param><embed src="http://www.youtube.com/v/G3KPBRajN10" type="application/x-shockwave-flash" wmode="transparent" width="425" height="344"></embed></object>', bayern.build_embed
  end

  def test_blip
    dn = ExternalVideo.new(:media_embed => '<embedOHNONOTREALLY src="http://blip.tv/play/AdS_C4P9Fg" type="application/x-shockwave-flash" width="320" height="270" allowscriptaccess="always" allowfullscreen="true">BLAHBLAHBLAH</embed> ')
    assert dn.valid?
    assert_equal :bliptv, dn.service_name
    assert_equal "AdS_C4P9Fg", dn.media_key
    assert_equal 320, dn.width.to_i
    assert_equal 270, dn.height.to_i
    assert_equal '<embed src="http://blip.tv/play/AdS_C4P9Fg" type="application/x-shockwave-flash" width="320" height="270" allowscriptaccess="always" allowfullscreen="true"></embed>', dn.build_embed
  end

  def test_vimeo
    dancing = ExternalVideo.new(:media_embed => '<object width="400" height="225">	<param name="allowfullscreen" value="true" />	<param name="allowscriptaccess" value="always" />	<param name="movie" value="http://vimeo.com/moogaloop.swf?clip_id=1211060&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" />	<embed src="http://vimeo.com/moogaloop.swf?clip_id=1211060&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" type="application/x-shockwave-flash" allowfullscreen="true" allowscriptaccess="always" width="400" height="225"></embed></object><br /><a href="http://vimeo.com/1211060?pg=embed&amp;sec=1211060">Where the Hell is Matt? (2008)</a> from <a href="http://vimeo.com/user484313?pg=embed&amp;sec=1211060">Matthew Harding</a> on <a href="http://vimeo.com?pg=embed&amp;sec=1211060">Vimeo</a>.')
    assert dancing.valid?
    assert_equal :vimeo, dancing.service_name
    assert_equal "1211060", dancing.media_key
  end
end
