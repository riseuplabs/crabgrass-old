require 'test/unit'
require 'rubygems'
require 'ruby-debug'
require 'yaml'

test_dir =  File.dirname(File.expand_path(__FILE__))
require test_dir + '/../greencloth.rb'

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
    assert_equal 'vegetables', greencloth.heading_tree.successor('pears').name
  end

  def test_get_text
    greencloth = GreenCloth.new( in_texts(:fruity_outline) )

    assert_equal "h2. Tasty Apples\n\nh3. Green\n\nh3. Red",
      greencloth.get_text_for_heading('tasty-apples')

    assert_equal "h1. Vegetables\n\nh2. Turnips\n\nh2. Green Beans",
      greencloth.get_text_for_heading('vegetables')

    assert_equal "h2. Pears", greencloth.get_text_for_heading('pears')
  end

  def test_weird_text
    greencloth = GreenCloth.new( in_texts(:weird_chars) )
    assert_equal "h1. i eat 'food'", greencloth.get_text_for_heading('i-eat-food')
  end

  def test_get_setext_style_headings
    greencloth = GreenCloth.new( in_texts(:setext_trees) )

    assert_equal "Evergreens\n==========\n\nh3. Cedar\n\nh3. Redwood\n\nh3. Fir",
      greencloth.get_text_for_heading('evergreens')

    assert_equal "Oaks\n----\n\nh3. White Oak\n\nh3. Red Oak",
      greencloth.get_text_for_heading('oaks')

    assert_equal "h3. Fir", greencloth.get_text_for_heading('fir')
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

  def test_multinine_heading
    greencloth = GreenCloth.new( in_texts(:multiline_headings) )

    assert_equal "h1. section one line one\nline two\n\nsection one text",
      greencloth.get_text_for_heading('section-one-line-one-line-two')

    assert_equal "h1. section two line one\nline two\n\nsection two text",
      greencloth.get_text_for_heading('section-two-line-one-line-two')
  end

  def test_link_with_whitespace_after_first_char
    greencloth = GreenCloth.new("[a link->http://example.com]")
    assert_equal "<p><a href=\"http://example.com\">a link</a></p>",
      greencloth.to_html
  end

  def test_anchor_link_with_whitespace_after_first_char
    greencloth = GreenCloth.new("[# link]")
    assert_equal "<p><a href=\"#link\">link</a></p>", greencloth.to_html
  end

  protected

  def in_texts(name)
    name = name.to_s.gsub('_',' ')
    text = (@fixtures[name]||{})['in']
    assert_not_nil text, 'could not find fixture data "%s"' % name
    return text
  end

end






