require 'test/unit'
require 'rubygems'
require 'ruby-debug'
require 'yaml'

test_dir =  File.dirname(File.expand_path(__FILE__))
require test_dir + '/../greencloth.rb'
require test_dir + '/../../extension/string'

class TestHeadings < Test::Unit::TestCase

  def setup
    testfile = File.dirname(__FILE__) + '/fixtures/outline.yml'
    @fixtures = {}
    YAML::load_documents( File.open( testfile ) ) do |doc|
      key = doc.delete("name")
      @fixtures[key] = doc
    end
  end

  def test_successive_heading
    greencloth = GreenCloth.new( in_texts(:fruity_outline) )

    assert_equal 'vegetables', greencloth.heading_tree.successor('fruits').name
    assert_equal 'pears', greencloth.heading_tree.successor('tasty-apples').name
    assert_equal nil, greencloth.heading_tree.successor('pears')
  end
  
  def test_get_text
    greencloth = GreenCloth.new( in_texts(:fruity_outline) )

    assert_equal "h2. Tasty Apples  \n\nh3. Green\n\nh3. Red",
      greencloth.get_text_for_heading('tasty-apples')

    assert_equal "h1. Vegetables\n\nh2. Turnips\n\nh2. Green Beans",
      greencloth.get_text_for_heading('vegetables')
  end
 
  def test_get_setext_style_headings
    greencloth = GreenCloth.new( in_texts(:setext_trees) )

    assert_equal "Evergreens \n==========\n\nh3. Cedar\n\nh3. Redwood\n\nh3. Fir",
      greencloth.get_text_for_heading('evergreens')

    assert_equal "Oaks\n----\n\nh3. White Oak\n\nh3. Red Oak",
      greencloth.get_text_for_heading('oaks')
  end

  def test_duplicate_names
    greencloth = GreenCloth.new( in_texts(:double_trouble) )

    assert_equal "h1. Title\n\nh3. Under first", greencloth.get_text_for_heading('title')

    assert_equal "h1. Title\n\nh3. Under second", greencloth.get_text_for_heading('title_2')
  end

  def test_set_text
    greencloth = GreenCloth.new( in_texts(:fruity_outline) )

    assert_equal "[[toc]]\n\nh1. Fruits\n\nxxxxx\n\nh2. Pears\n\nh1. Vegetables\n\nh2. Turnips\n\nh2. Green Beans", greencloth.dup.set_text_for_heading('tasty-apples', 'xxxxx')

    assert_equal "[[toc]]\n\nh1. Fruits\n\nh2. Oranges\n\nooooo\n\nh2. Pears\n\nh1. Vegetables\n\nh2. Turnips\n\nh2. Green Beans", greencloth.dup.set_text_for_heading('tasty-apples', "h2. Oranges\n\nooooo")
  end

  protected
  
  def in_texts(name)
    name = name.to_s.gsub('_',' ')
    text = (@fixtures[name]||{})['in']
    assert_not_nil text, 'could not find fixture data "%s"' % name
    return text
  end

end






