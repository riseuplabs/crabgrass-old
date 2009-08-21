require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class HpricotExtensionsTest < Test::Unit::TestCase
  GET_ELEM = lambda {|content| Hpricot(content).children[0]}

  def setup_elements
    @p_without_styles   = GET_ELEM.call("<p>some text inside</p>")
    @p_with_styles      = GET_ELEM.call("<p styles='font-weight:bold; color:#000; font-style: italic'>some text inside</p>")
    @img_without_styles = GET_ELEM.call("<img src='some.jpg' />")
  end

  context "Hpricot::Styles extensions" do
    setup do
      setup_elements
    end

    test "get a hash of all styles from an element" do
      assert_kind_of Hpricot::Styles, @p_with_styles.styles
    end

    test "add new style to an element trough Elem" do
      @p_without_styles.set_style("color", "red")
      assert_equal({"color" => "red"}, @p_without_styles.styles.to_h)
    end
    
    test "add new style to an element trough Styles" do
      @p_without_styles.styles["color"] = "red"
      assert_equal({"color" => "red"}, @p_without_styles.styles.to_h)
    end
  end
  
  context "Hpricot::Elem extensions" do
    setup do
      setup_elements
    end

    test "change an element tag name preserving attributes" do
      @p_with_styles.change_tag! "span"
      assert_equal "<span styles=\"font-weight:bold; color:#000; font-style: italic\">some text inside</span>", @p_with_styles.to_s
    end
    
    test "change an element tag name not preserving attributes" do
      @p_with_styles.change_tag! "span", false
      assert_equal "<span>some text inside</span>", @p_with_styles.to_s
    end
    
    test "ignore self closed element tag name" do
      @img_without_styles.change_tag! "hr"
      assert_equal "<img src=\"some.jpg\" />", @img_without_styles.to_s
    end
  end
end
