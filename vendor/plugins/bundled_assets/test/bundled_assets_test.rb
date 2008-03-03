require 'test/unit' 

$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

ENV['RAILS_ENV'] ||= 'test'

require 'assets_bundle'
require File.dirname(__FILE__) + '/../init.rb'

class BundledAssetsOptionsTest < Test::Unit::TestCase 
  def setup 
    @bundle = AssetsBundle.new 'a,b', 'css'
  end 
  def test_should_use_defaults
    assert @bundle.compress?
    assert @bundle.css_keep_comments? == false
    assert @bundle.jsmin =~ /^ruby .*jsmin\.rb$/
  end
  def test_should_overwrite_defaults
    @bundle.options = { :compress => :js, 
                        :css_keep_comments => true,
                        :jsmin => 'path/to/custom/jsmin' }
    assert @bundle.compress? == false
    assert @bundle.css_keep_comments? == true
    assert @bundle.jsmin == 'path/to/custom/jsmin'
  end
end

class BundledAssetsCssWithCompressionTest < Test::Unit::TestCase 
  def setup 
    @bundle = AssetsBundle.new 'a,b', 'css'
  end 
  def test_should_compress
    assert @bundle.compress?
  end
  def test_should_find_files
    assert_equal 2, @bundle.filenames.size
  end
  def test_should_merge_css_files
    assert_equal ".a-class {display: none}\n.b-class {display: block}", @bundle.content
  end
end

class BundledAssetsJsWithCompressionTest < Test::Unit::TestCase 
  def setup 
    @bundle = AssetsBundle.new 'a,b', 'js'
  end 
  def test_should_compress
    assert_equal "function somefunction(){var var_1=1;var var_2=2\nfor(var i=0;i<1;i++){alert('something')}}", @bundle.content
  end
end

class BundledAssetsCssWithoutCompressionTest < Test::Unit::TestCase 
  def setup 
    @bundle = AssetsBundle.new 'a,b', 'css', {:compress => false}
  end 
  def test_should_compress
    assert @bundle.compress? == false
  end
  def test_should_merge_css_files
    assert_equal ".a-class {\n\tdisplay: none;\n}\n.b-class {\n\tdisplay: block;\n}", @bundle.content
  end
end