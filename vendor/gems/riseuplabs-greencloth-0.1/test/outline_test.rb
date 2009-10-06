require 'test/unit'
require 'rubygems'
require 'ruby-debug'
require 'yaml'

test_dir =  File.dirname(File.expand_path(__FILE__))
require test_dir + '/../lib/greencloth.rb'

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
    tree = greencloth.green_tree

    assert_equal 'vegetables', tree.find('fruits').successor.name
    assert_equal 'pears', tree.find('tasty-apples').successor.name
    assert_equal 'vegetables', tree.find('pears').successor.name
  end

  def test_badly_organized_successive_heading
    greencloth = GreenCloth.new( in_texts(:badly_organized_fruits) )
    tree = greencloth.green_tree

    assert_equal 'vegetables', tree.find('fruits').successor.name
    assert_equal 'tasty-apples', tree.find('green-apples').successor.name
    assert_equal 'pears', tree.find('tasty-apples').successor.name
  end

  def test_get_text
    greencloth = GreenCloth.new( in_texts(:fruity_outline) )
    tree = greencloth.green_tree

    assert_equal "h2. Tasty Apples\n\nh3. Green\n\nh3. Red\n\n",
      tree.find('tasty-apples').markup

    assert_equal "h1. Vegetables\n\nh2. Turnips\n\nh2. Green Beans",
      tree.find('vegetables').markup

    assert_equal "h2. Pears\n\n", tree.find('pears').markup
  end

  def test_weird_text
    greencloth = GreenCloth.new( in_texts(:weird_chars) )
    tree = greencloth.green_tree

    assert_equal "h1. i eat 'food'\n\n", tree.find('i-eat-food').markup
  end

  def test_get_setext_style_headings
    greencloth = GreenCloth.new( in_texts(:setext_trees) )
    tree = greencloth.green_tree

    assert_equal "Evergreens\n==========\n\nh3. Cedar\n\nh3. Redwood\n\nh3. Fir\n\n",
      tree.find('evergreens').markup

    assert_equal "Oaks\n----\n\nh3. White Oak\n\nh3. Red Oak",
      tree.find('oaks').markup

    assert_equal "h3. Fir\n\n", tree.find('fir').markup
  end

  def test_duplicate_names
    greencloth = GreenCloth.new( in_texts(:double_trouble) )
    tree = greencloth.green_tree

    assert_equal "h1. Title\n\nh3. Under first\n\n", tree.find('title').markup
    assert_equal "h1. Title\n\nh3. Under second", tree.find('title_2').markup
  end

  def test_set_text
    greencloth = GreenCloth.new( in_texts(:fruity_outline) )
    tree = greencloth.green_tree

    assert_equal "[[toc]]\n\nh1. Fruits\n\nxxxxx\n\nh2. Pears\n\nh1. Vegetables\n\nh2. Turnips\n\nh2. Green Beans", tree.find('tasty-apples').sub_markup('xxxxx')

    assert_equal "[[toc]]\n\nh1. Fruits\n\nh2. Oranges\n\nooooo\n\nh2. Pears\n\nh1. Vegetables\n\nh2. Turnips\n\nh2. Green Beans", tree.find('tasty-apples').sub_markup("h2. Oranges\n\nooooo")
  end

  def test_multinine_heading
    greencloth = GreenCloth.new( in_texts(:multiline_headings) )
    tree = greencloth.green_tree

    assert_equal "h1. section one line one\nline two\n\nsection one text\n\nh2. subsection\nwithout content\n\n",
      tree.find('section-one-line-one-line-two').markup

    assert_equal "h1. section two line one\nline two\n\nsection two text",
      tree.find('section-two-line-one-line-two').markup
  end

  def test_nested_sections
    greencloth = GreenCloth.new( in_texts(:weird_and_nested) )
    tree = greencloth.green_tree

    assert_equal "h1. Highest\n\nlower\n-----------\n\nlower text\n\nh2. even lower\n\nh3. lowest\n\nlowest text\n\nh3. lowest and blankest\n\n",
      tree.find('highest').markup

    assert_equal "lower\n-----------\n\nlower text\n\n",
      tree.find('lower').markup

    assert_equal "h2. even lower\n\nh3. lowest\n\nlowest text\n\nh3. lowest and blankest\n\n",
      tree.find('even-lower').markup

    assert_equal "h3. lowest\n\nlowest text\n\n",
      tree.find('lowest').markup

    assert_equal "h3. lowest and blankest\n\n",
      tree.find('lowest-and-blankest').markup

    assert_equal "high as they get\n=================\n\nh2. underling\n\nunderling text",
      tree.find('high-as-they-get').markup

    assert_equal "h2. underling\n\nunderling text",
      tree.find('underling').markup
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

  def test_set_text_around_untitled_section
    greencloth = GreenCloth.new( in_texts(:untitled_leading_section) )
    tree = greencloth.green_tree

    assert_equal "\nwelcome to our great list of fruits and vegetables\n\nh1. No Fruits\n\nh1. Vegetables\n\nh2. Green Beans", tree.find('fruits').sub_markup('h1. No Fruits')
  end

  def test_plain_old_text
    greencloth = GreenCloth.new( in_texts(:plain_old_text) )
    tree = greencloth.green_tree

    assert_equal [], tree.section_names
    assert_equal greencloth.size - 1, tree.end_index
  end

  def test_overdecorated
    greencloth = GreenCloth.new( in_texts(:overdecorated) )
    tree = greencloth.green_tree

    section_markup_map = {
      'emphasis' => "h2. _emphasis_\n\n",
      'italicized' => "__italicized__\n--------------\n\n",
      'strong' => "h2. *strong*\n\n",
      'bold' => "**bold**\n--------\n\n",
      'citation' => "h2. ??citation??\n\n",
      'deleted-text' => "-deleted text-\n--------------\n\n",
      'inserted-text' => "h2. +inserted text+\n\n",
      'superscript' => "^superscript^\n-------------\n\n",
      'subscript' => "h2. ~subscript~\n\n",
      'code' => "@code@\n------\n\n",
      'table' => "h2. [-table-]"

    }

    section_markup_map.each do |section, markup|
      assert_equal markup, tree.find(section).markup
    end
  end

  protected

  def in_texts(name)
    name = name.to_s.gsub('_',' ')
    text = (@fixtures[name]||{})['in']
    assert_not_nil text, 'could not find fixture data "%s"' % name
    return text
  end

end






