require File.dirname(__FILE__) + '/../test_helper'

class Site < ActiveRecord::Base
  def self.uncache_default
    @default_size = nil
  end
end

class SiteTest < Test::Unit::TestCase
  fixtures :sites

  def test_defaults_to_conf
    assert_equal Conf.title, Site.new.title
  end


end
