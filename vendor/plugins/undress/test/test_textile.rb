require File.expand_path(File.dirname(__FILE__) + "/test_helper")

module Undress
  class TextileTest < Test::Unit::TestCase
    def assert_renders_textile(textile, html)
      assert_equal textile, Undress(html).to_textile
    end

    context "Converting HTML to textile" do
      test "converts nested tags" do
        assert_renders_textile "h2. _this is *very* important_\n", "<h2><em>this is <strong>very</strong> important</em></h2>"
      end

      context "inline elements" do
        test "converts <strong> tags" do
          assert_renders_textile "*foo bar*", "<strong>foo bar</strong>"
        end

        test "converts <em> tags" do
          assert_renders_textile "_foo bar_", "<em>foo bar</em>"
        end

        test "converts <code> tags" do
          assert_renders_textile "@foo bar@", "<code>foo bar</code>"
        end

        test "converts <cite> tags" do
          assert_renders_textile "??foo bar??", "<cite>foo bar</cite>"
        end

        test "converts <sup> tags" do
          assert_renders_textile "foo ^sup^ bar", "foo <sup>sup</sup> bar"
          assert_renders_textile "foo[^sup^]bar", "foo<sup>sup</sup>bar"
        end

        test "converts <sub> tags" do
          assert_renders_textile "foo ~sub~ bar", "foo <sub>sub</sub> bar"
          assert_renders_textile "foo[~sub~]bar", "foo<sub>sub</sub>bar"
        end

        test "converts <ins> tags" do
          assert_renders_textile "+foo bar+", "<ins>foo bar</ins>"
        end

        test "converts <del> tags" do
          assert_renders_textile "-foo bar-", "<del>foo bar</del>"
        end

        test "converts <acronym> tags" do
          assert_renders_textile "EPA(Environmental Protection Agency)", "<acronym title='Environmental Protection Agency'>EPA</acronym>"
          assert_renders_textile "EPA", "<acronym>EPA</acronym>"
        end
      end

      context "links" do
        test "converts simple links (without title)" do
          assert_renders_textile "[Foo Bar:/cuack]", "<a href='/cuack'>Foo Bar</a>"
        end

        test "converts links with titles" do
          assert_renders_textile "[Foo Bar (You should see this):/cuack]", "<a href='/cuack' title='You should see this'>Foo Bar</a>"
        end
      end

      context "images" do
        test "converts images without alt attributes" do
          assert_renders_textile "!http://example.com/image.png!", "<img src='http://example.com/image.png'/>"
        end

        test "converts images with alt attributes" do
          assert_renders_textile "!http://example.com/image.png(Awesome Pic)!", "<img src='http://example.com/image.png' alt='Awesome Pic'/>"
        end
      end

      context "text formatting" do
        test "converts paragraphs" do
          assert_renders_textile "foo\n\nbar\n", "<p>foo</p><p>bar</p>"
        end

        test "converts <pre> tags which only contain a <code> child" do
          assert_renders_textile "pc. var foo = 1;\n", "<pre><code>var foo = 1;</code></pre>"
          assert_renders_textile "pc. var foo = 1;\n", "<pre>   <code>var foo = 1;</code>   </pre>"
        end

        test "leaves <pre> tags which contain mixed content as HTML" do
          assert_renders_textile "<pre>  foo bar</pre>", "<pre>  foo bar</pre>"
        end

        test "converts <br> into a new line" do
          assert_renders_textile "Foo\nBar", "Foo<br/>Bar"
        end

        test "converts blockquotes" do
          assert_renders_textile "bq. foo bar\n", "<blockquote><div>foo bar</div></blockquote>"
        end
      end

      context "headers" do
        test "converts <h1> tags" do
          assert_renders_textile "h1. foo bar\n", "<h1>foo bar</h1>"
        end

        test "converts <h2> tags" do
          assert_renders_textile "h2. foo bar\n", "<h2>foo bar</h2>"
        end

        test "converts <h3> tags" do
          assert_renders_textile "h3. foo bar\n", "<h3>foo bar</h3>"
        end

        test "converts <h4> tags" do
          assert_renders_textile "h4. foo bar\n", "<h4>foo bar</h4>"
        end

        test "converts <h5> tags" do
          assert_renders_textile "h5. foo bar\n", "<h5>foo bar</h5>"
        end

        test "converts <h6> tags" do
          assert_renders_textile "h6. foo bar\n", "<h6>foo bar</h6>"
        end
      end

      context "lists" do
        test "converts bullet lists" do
          assert_renders_textile "* foo\n* bar\n", "<ul><li>foo</li><li>bar</li></ul>"
        end

        test "converts numbered lists" do
          assert_renders_textile "# foo\n# bar\n", "<ol><li>foo</li><li>bar</li></ol>"
        end

        test "converts nested bullet lists" do
          assert_renders_textile "* foo\n** bar\n* baz\n", "<ul><li>foo<ul><li>bar</li></ul></li><li>baz</li></ul>"
        end

        test "converts nested numbered lists" do
          assert_renders_textile "# foo\n## bar\n# baz\n", "<ol><li>foo<ol><li>bar</li></ol></li><li>baz</li></ol>"
        end

        test "converts nested mixed lists" do
          assert_renders_textile "* foo\n## bar\n## baz\n*** quux\n* cuack\n",
                                 "<ul><li>foo<ol><li>bar</li><li>baz<ul><li>quux</li></ul></li></ol></li><li>cuack</li></ul>"
        end

        test "converts a definition list" do
          assert_renders_textile "- foo := defining foo =:\n- bar := defining bar =:\n",
                                 "<dl><dt>foo</dt><dd>defining foo</dd><dt>bar</dt><dd>defining bar</dd></dl>"
        end
      end

      context "tables" do
        test "converts a simple table" do
          assert_renders_textile "|foo|bar|baz|\n|1|2|3|\n",
                                 "<table><tr><td>foo</td><td>bar</td><td>baz</td></tr><tr><td>1</td><td>2</td><td>3</td></tr></table>"
        end

        test "converts a table with headers" do
          assert_renders_textile "|_. foo|_. bar|_. baz|\n|1|2|3|\n",
                                 "<table><tr><th>foo</th><th>bar</th><th>baz</th></tr><tr><td>1</td><td>2</td><td>3</td></tr></table>"
        end

        test "converts a table with cells that span multiple columns" do
          assert_renders_textile "|foo|bar|baz|\n|\\2. 1|2|\n",
                                 "<table><tr><td>foo</td><td>bar</td><td>baz</td></tr><tr><td colspan='2'>1</td><td>2</td></tr></table>"
        end

        test "converts a table with cells that span multiple rows" do
          assert_renders_textile "|/2. foo|bar|baz|\n|1|2|\n",
                                 "<table><tr><td rowspan='2'>foo</td><td>bar</td><td>baz</td></tr><tr><td>1</td><td>2</td></tr></table>"
        end
      end

      context "applying post processing rules" do
        test "compresses newlines to a maximum of two consecutive newlines" do
          assert_renders_textile "Foo\n\nBar\n\nBaz\n\n* Quux 1\n* Quux 2\n", "<p>Foo</p><p>Bar</p><p>Baz</p><ul><li>Quux 1</li><li>Quux 2</li></p>"
        end

        test "strips trailing newlines from the start and end of the output string" do
          assert_renders_textile "Foo\n", "<p>Foo</p>"
        end

        test "converts all fancy characters introduced by textile back into their 'source code'" do
          assert_renders_textile "What the ... hell?", "What the &#8230; hell?"
          assert_renders_textile "It's mine", "It&#8217;s mine"
          assert_renders_textile "\"Fancy quoting\"", "&#8220;Fancy quoting&#8221;"
          assert_renders_textile "How dashing--right?", "How dashing&#8212;right?"
          assert_renders_textile "How dashing - right?", "How dashing &#8211; right?"
          assert_renders_textile "2 x 2 = 4", "2 &#215; 2 = 4"
          assert_renders_textile "2x2 = 4", "2&#215;2 = 4"
          assert_renders_textile "Registered(r)", "Registered&#174;"
          assert_renders_textile "Copyrighted(c)", "Copyrighted&#169;"
          assert_renders_textile "Trademarked(tm)", "Trademarked&#8482;"
        end
      end
    end
  end
end
