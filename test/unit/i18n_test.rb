require File.dirname(__FILE__) + '/../test_helper'

class I18nTest < ActiveSupport::TestCase

  def setup
    I18n.backend = I18n::Backend::Simple.new
    I18n.backend.stubs(:initialized?).returns(true)
  end

  def teardown
    I18n.backend = nil
  end

  def add_translation(locale, dictionary)
    I18n.backend.send(:merge_translations, locale, dictionary)
  end


  def test_site_translations
    site = Site.new(:name => "thediggers")


    add_translation(:en, {
                          :test_title => "Hello {{what}}",
                          :test_name => "default {{what}}",
                          :thediggers => {
                              :test_title => "{{what}} come to dig and sow."}})

    Site.stubs(:current).returns(site)
    assert_equal "We come to dig and sow.", I18n.translate(:test_title, :what => "We"), "Site specific translation should come up when Site.current is set"
    assert_equal "We come to dig and sow.", I18n.t(:test_title, :what => "We"), "Site specific translation should come up when Site.current is set"

    assert_equal "default name", I18n.t(:test_name, :what => "name"), "Site specific translations should fall-back to language translations"

    Site.stubs(:current).returns(Site.default)
    assert_equal "Hello World", I18n.t(:test_title, :what => "World"), "Site specific translation should only appear for the right site"
  end
end
