require File.dirname(__FILE__) + '/../test_helper'

require File.dirname(__FILE__) + '/wiki/locking_test.rb'
require File.dirname(__FILE__) + '/wiki/rendering_test.rb'
require File.dirname(__FILE__) + '/wiki/saving_test.rb'
require File.dirname(__FILE__) + '/wiki/versioning_test.rb'

class WikiTest < Test::Unit::TestCase
  fixtures :users, :wikis

  def setup
    @blue = users(:blue)
    @red = users(:red)
  end


  def self.should_have_latest_body body
    should "have the latest body" do
      assert_equal body, @wiki.body
    end

    should "have the latest body for its most recent version" do
      assert_equal body, @wiki.versions.last.body
    end
  end

  def self.should_have_latest_body_html body_html
    should "have the latest body_html" do
      assert_equal body_html, @wiki.body_html
    end

    should "have the latest body_html for its most recent version" do
      assert_equal body_html, @wiki.versions.last.body_html
    end
  end

  def self.should_have_latest_raw_structure raw_structure
    should "have the latest raw_structure" do
      assert_equal raw_structure, @wiki.raw_structure
    end

    should "have the latest raw_structure for its most recent version" do
      assert_equal raw_structure, @wiki.versions.last.raw_structure
    end
  end

  include Wiki::LockingTest
  # include Wiki::RenderingTest
  # include Wiki::VersioningTest
  # include Wiki::SavingTest

  should "Wiki have good associations" do
    assert(check_associations(Wiki))
  end
end
