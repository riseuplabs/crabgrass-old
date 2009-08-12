require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class UglifyHtmlTest < Test::Unit::TestCase
  def assert_renders_uglify(uglify, html)
    assert_equal uglify, UglifyHtml.new(html).make_ugly
  end

  context "convert common tags" do
    test "it should convert a simple <strong> tag" do
      html = "<p>some <strong>bold</strong> text inside a paragraph</p>"
      uglify = "<p>some <span style=\"font-weight:bold\">bold</span> text inside a paragraph</p>"
      assert_renders_uglify uglify, html 
    end

    test "it should convert a <strong> nested on a <em>" do
      html = "<p>some <em><strong>em bold</strong></em> text inside a paragraph</p>"
      uglify = "<p>some <span style=\"font-style:italic;font-weight:bold\">em bold</span> text inside a paragraph</p>"
      assert_renders_uglify uglify, html 
    end
    
    test "it should convert a <ins> tag" do
      html = "<p>some <ins>underline</ins> text inside a paragraph</p>"
      uglify = "<p>some <span style=\"text-decoration:underline\">underline</span> text inside a paragraph</p>"
      assert_renders_uglify uglify, html 
    end
    
    test "it should convert a <del> tag" do
      html = "<p>some <del>deleted</del> text inside a paragraph</p>"
      uglify = "<p>some <span style=\"text-decoration:line-through\">deleted</span> text inside a paragraph</p>"
      assert_renders_uglify uglify, html 
    end
  end

  context "convert lists" do
    test "it should convert a simple ul nested list" do
      html = "<ul><li>item 1</li><li>item 2<ul><li>nested 1 item 1</li></ul></li></ul>"
      uglify = "<ul><li>item 1</li><li>item 2</li><ul><li>nested 1 item 1</li></ul></ul>"
      assert_renders_uglify uglify, html 
    end
    
    test "it should convert a simple ol nested list" do
      html = "<ol><li>item 1</li><li>item 2<ol><li>nested 1 item 1</li></ol></li></ol>"
      uglify = "<ol><li>item 1</li><li>item 2</li><ol><li>nested 1 item 1</li></ol></ol>"
      assert_renders_uglify uglify, html 
    end
  end
end
