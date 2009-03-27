require File.dirname(__FILE__) + '/../test_helper'

class Site < ActiveRecord::Base
  def self.uncache_default
    @default_size = nil
  end
end

class SiteTest < Test::Unit::TestCase
  fixtures :sites

  def test_default
    first_site = Site.find :first
    first_default = Site.find :first, :conditions => ["sites.default = '?'", true]

    site_default = Site.default

    assert site_default.default, "site.default field should be true"
    # unset the first default
    site_default.default = false
    site_default.save!
    Site.uncache_default

    default = Site.default
    assert_equal false, default.default, "site.default field should be false"
    assert_equal first_site, default
  end

end
