require File.expand_path(File.dirname(__FILE__) + "/test_helper")

module Undress
  class TestGrammar < Test::Unit::TestCase
    class Parent < Grammar
      rule_for(:p) {|e| "<this is a paragraph>#{content_of(e)}</this is a paragraph>" }
    end

    class WithPreProcessingRules < Parent
      pre_processing("p.foo") {|e| e.swap("<div>Cuack</div>") }
      rule_for(:div) {|e| "<this was a div>#{content_of(e)}</this was a div>" }
    end

    class Child < Parent; end

    class OverWriter < WithPreProcessingRules
      rule_for(:div) {|e| content_of(e) }
    end

    class TextileExtension < Textile
      rule_for(:a) {|e| "" }
    end

    class WithAttributes < Parent
      whitelist_attributes :id, :class
    end

    def parse_with(grammar, html)
      grammar.process!(Hpricot(html))
    end

    context "extending a grammar" do
      test "the extended grammar should inherit the rules of the parent" do
        output = parse_with Child, "<p>Foo Bar</p>"
        assert_equal "<this is a paragraph>Foo Bar</this is a paragraph>", output
      end

      test "extending a grammar doesn't overwrite the parent's rules" do
        output = parse_with OverWriter, "<div>Foo</div>"
        assert_equal "Foo", output

        output = parse_with WithPreProcessingRules, "<div>Foo</div>"
        assert_equal "<this was a div>Foo</this was a div>", output
      end

      test "extending textile doesn't blow up" do
        output = parse_with TextileExtension, "<p><a href='/'>Cuack</a></p><p>Foo Bar</p><p>I <a href='/'>work</a></p>"
        assert_equal "Foo Bar\n\nI\n", output
      end
    end

    context "pre processing rules" do
      test "mutate the DOM before parsing the tags" do
        output = parse_with WithPreProcessingRules, "<p class='foo'>Blah</p><p>O hai</p>"
        assert_equal "<this was a div>Cuack</this was a div><this is a paragraph>O hai</this is a paragraph>", output
      end
    end

    context "handles attributes" do
      def attributes_for_tag(html)
        WithAttributes.new.attributes(Hpricot(html).children.first)
      end

      test "whitelisted attributes are picked up in the attributes hash" do
        attributes = attributes_for_tag("<p class='foo bar' id='baz'>Cuack</p>")
        assert_equal({ :class => "foo bar", :id => "baz" }, attributes)
      end

      test "attributes that are not in the whitelist are ignored" do
        attributes = attributes_for_tag("<p lang='es' id='saludo'>Hola</p>")
        assert_equal({ :id => "saludo" }, attributes)
      end
    end
  end
end
