require File.dirname(__FILE__) + '/../test_helper'

class I18nTest < ActiveSupport::TestCase

  def setup
    I18n.backend = I18n::Backend::Simple.new
    I18n.backend.stubs(:initialized?).returns(true)
    I18n.locale = :en

    add_translation(:en, {
                           :test_title => "Hello {{what}}",
                           :test_name => "default {{what}}",
                           :say_hi => "OH HAI",
                           :thediggers => {
                               :test_title => "{{what}} come to dig and sow.",
                               :say_hi => "hi diggers"}})
    add_translation(:bw, {
                           :test_title => "Olleh {{what}}",
                           :test_name => "tluafed {{what}}",
                           :thediggers => {
                               :test_title => "wos dna gid ot emoc {{what}}"}})

    @site = Site.new(:name => "thediggers")
  end

  def teardown
    I18n.backend = nil
  end

  def add_translation(locale, dictionary)
    I18n.backend.send(:merge_translations, locale, dictionary)
  end


  def test_site_specific_translation_scope_is_added
    Site.stubs(:current).returns(@site)
    assert_equal "We come to dig and sow.", I18n.translate(:test_title, :what => "We"), "Site specific translation should come up when Site.current is set"
    assert_equal "We come to dig and sow.", I18n.t(:test_title, :what => "We"), "Site specific translation should come up when Site.current is set"

    I18n.locale = :bw
    assert_equal "wos dna gid ot emoc We", I18n.translate(:test_title, :what => "We"), "Site specific translation should come up for a different language"
    assert_equal "wos dna gid ot emoc We", I18n.t(:test_title, :what => "We"), "Site specific translation should come up for a different language"
  end

  def test_without_site_language_translations_are_used
    Site.stubs(:current).returns(Site.default)

    assert_equal "Hello World", I18n.t(:test_title, :what => "World"), "Default language translations should be available"
    assert_equal "Hello World", I18n.translate(:test_title, :what => "World"), "Default language translations should be available"

    I18n.locale = :bw
    assert_equal "Olleh World", I18n.t(:test_title, :what => "World"), "Default language translations should be available"
    assert_equal "Olleh World", I18n.translate(:test_title, :what => "World"), "Default language translations should be available"
  end

  def test_fallback_to_default_language
    Site.stubs(:current).returns(@site)
    assert_equal "default name", I18n.t(:test_name, :what => "name"), "Site specific translations should fall-back to language translations"
    assert_equal "default name", I18n.t(:test_name, :what => "name", :locale => :en), "Site specific translations should fall-back to language translations"

    assert_equal "tluafed name", I18n.t(:test_name, :what => "name", :locale => :bw), "Site specific translations should fall-back to the right language translations"
    assert_equal "hi diggers", I18n.t(:say_hi, :locale => :bw), "translations should fallback to english locale for site-specific translations"

    I18n.locale = :bw
    assert_equal "tluafed name", I18n.t(:test_name, :what => "name"), "Site specific translations should fall-back to the right language translations"
    assert_equal "hi diggers", I18n.t(:say_hi), "translations should fallback to english locale for site-specific translations"


    Site.stubs(:current).returns(Site.default)
    assert_equal "OH HAI", I18n.t(:say_hi), "translations should fallback to english locale for non-site-specific translations"
  end

end
