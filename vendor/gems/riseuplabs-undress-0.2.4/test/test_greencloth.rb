require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class Undress::GreenClothTest < Test::Unit::TestCase
  def assert_renders_greencloth(greencloth, html)
    assert_equal greencloth, Undress(html).to_greencloth
  end

  def assert_not_renders_greencloth(greencloth, html)
    assert_not_equal greencloth, Undress(html).to_greencloth
  end

  context "parsing badly indented documents" do
    test "badly indent doc" do
      html = "<ul>
                <li>foo</li>
                <li>bar</li>
                <li>and x is also.</li>
              </ul>"
      greencloth = "* foo\n* bar\n* and x is also.\n"
      assert_renders_greencloth greencloth, html 
    end
  end

  context "some troubles with empty tags" do
    test "with pre" do
      html = "<pre></pre>"
      greencloth = "<pre></pre>"
      assert_renders_greencloth greencloth, html 
    end

    test "with p" do
      html = "<p></p>"
      greencloth = ""
      assert_renders_greencloth greencloth, html 
    end
  end

  # TODO:
  # this is ok to ensure invalid html -> to greencloth but xhtmlize! must have
  # tests on test_undress or something too
  context "parsing not valid xhtml documents" do
    context "with tables" do
      test "cells should not have spaces at the start/end inside" do
        html = "<table>  <tbody>  <tr class='odd'>  <th>&nbsp;1&nbsp;<br></th>  <th>2<br/>&nbsp;</th>  </tr>  <tr class='even'>  <td>&nbsp;11<br/></td>  <td>22</td>  </tr>  </tbody>  </table>"
        greencloth = "|_. 1|_. 2|\n|11|22|\n"
        assert_renders_greencloth greencloth, html 
      end

      test "tables should not have <br> inside <td> and <th>" do
        html = "<table>  <tbody>  <tr class='odd'>  <th>1<br></th>  <th>2<br/></th>  </tr>  <tr class='even'>  <td>11<br/></td>  <td>22</td>  </tr>  </tbody>  </table>"
        greencloth = "|_. 1|_. 2|\n|11|22|\n"
        assert_renders_greencloth greencloth, html 
      end
      
      test "tables should not have spases beetween <td> inside" do
        html = "<table>  <tbody>  <tr class='odd'>  <td>1</td>  <td>2</td>  </tr>  <tr class='even'>  <td>11</td>  <td>22</td>  </tr>  </tbody>  </table>"
        greencloth = "|1|2|\n|11|22|\n"
        assert_renders_greencloth greencloth, html 
      end
    end

    test "with <u> tags" do
      html = "<u>underline</u>"
      greencloth = "+underline+"
      assert_renders_greencloth greencloth, html 
    end

    test "with<strike> tags" do
      html = "some <strike>strike</strike> text"
      greencloth = "some -strike- text"
      assert_renders_greencloth greencloth, html 
    end

    test "space between 2 spans with styles" do
      html = "<p><span style='font-weight: bold;'>bold</span> <span style='font-style: italic;'>italic</span></p>"
      greencloth = "*bold* _italic_\n"
      assert_renders_greencloth greencloth, html 
    end

    test "a <span> bold, italic, underline, line-through at the same time" do
      html = "<p>some text <span style='font-weight:bold; font-style:italic; text-decoration:underline;'>bold</span> with style</p>"
      greencloth = "some text *+_bold_+* with style\n"
      assert_renders_greencloth greencloth, html 
    end

    test "font-weight:bold styles in <span> elements should be <strong>" do
      html = "<p>some text <span style='font-weight:bold'>bold</span> with style</p>"
      greencloth = "some text *bold* with style\n"
      assert_renders_greencloth greencloth, html 
      html = "<p style='font-weight:bold'>some text bold with style</p>"
      greencloth = "*some text bold with style*\n"
      assert_renders_greencloth greencloth, html 
    end

    test "style 'line-through' should be converted to <del> in <span> elements" do
	    html = "<p>with <span style='text-decoration: line-through;'>some</span> in the <span style='text-decoration: line-through;'>paragraph</span></p>"
      greencloth = "with -some- in the -paragraph-\n"
      assert_renders_greencloth greencloth, html 
	    html = "<p style='text-decoration: line-through;'>with some in the paragraph</p>"
      greencloth = "-with some in the paragraph-\n"
      assert_renders_greencloth greencloth, html 
    end

    test "style 'underline' should be converted to <ins> in <span> elements" do
	    html = "<p>with <span style='text-decoration: underline;'>some</span> in the <span style='text-decoration: underline;'>paragraph</span></p>"
      greencloth = "with +some+ in the +paragraph+\n"
      assert_renders_greencloth greencloth, html 
	    html = "<p style='text-decoration: underline;'>with some in the paragraph</p>"
      greencloth = "+with some in the paragraph+\n"
      assert_renders_greencloth greencloth, html 
    end

    test "style 'italic' should be converted to <em> in <span> elements" do
	    html = "<p>with <span style='font-style: italic;'>some</span> in the <span style='font-style: italic;'>paragraph</span></p>"
      greencloth = "with _some_ in the _paragraph_\n"
      assert_renders_greencloth greencloth, html 
	    html = "<p style='font-style: italic;'>with some in the paragraph</p>"
      greencloth = "_with some in the paragraph_\n"
      assert_renders_greencloth greencloth, html 
    end

    test "a nested invalid unordered list" do
      html = "<ul><li>item 1</li><li>item 2</li><ul><li>nested 1</li><li>nested 2</li></ul><li>item 3</li></ul>"
      greencloth = "* item 1\n* item 2\n** nested 1\n** nested 2\n* item 3\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "a nested invalid ordered list" do
      html = "<ol><li>item 1</li><li>item 2</li><ol><li>nested 1</li><li>nested 2</li></ol><li>item 3</li></ol>"
      greencloth = "# item 1\n# item 2\n## nested 1\n## nested 2\n# item 3\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "a nested invalid mixed list with 3 levels" do
      html = "<ul><li>item 1</li><li>item 2</li><ol><li>nested 1</li><li>nested 2</li><ul><li>nested2 1</li><li>nested2 2</li></ul></ol><li>item 3</li></ul>"
      greencloth = "* item 1\n* item 2\n*# nested 1\n*# nested 2\n*#* nested2 1\n*#* nested2 2\n* item 3\n"
      assert_renders_greencloth greencloth, html 
    end

    test "a nested invalid mixed list" do
      html = "<ul><li>item 1</li><li>item 2</li><ol><li>nested 1</li><li>nested 2</li></ol><li>item 3</li></ul>"
      greencloth = "* item 1\n* item 2\n*# nested 1\n*# nested 2\n* item 3\n"
      assert_renders_greencloth greencloth, html 
    end

    test "2 badly nested list inside" do
      html = "<ul><li>item 1</li><li>item 2</li><ul><li>nested 1</li><ul><li>item 1x</li><li>item 2x</li></ul><li>nested 2</li></ul><li>item 3</li></ul>"
      greencloth = "* item 1\n* item 2\n** nested 1\n*** item 1x\n*** item 2x\n** nested 2\n* item 3\n"
      assert_renders_greencloth greencloth, html 
    end
  end

  # unallowed tags
  context "remove unallowed tags" do
    test "remove a head tag" do
      html = "<html><head><title>Title</title></head>"
      greencloth = ""
      assert_renders_greencloth greencloth, html 
    end

    test "remove a script tag" do
      html = "<div>Some script inside a<script type='text/javascript'>window.alert('alert')</script> paragraph</div>"
      greencloth = "Some script inside a paragraph"
      assert_renders_greencloth greencloth, html 
    end
  end

  # code
  context "converting code tags" do
    test "a code inside a paragraph" do
      html = "<p>do you like my <code>function</code>?</p>"
      greencloth = "do you like my @function@?\n"
      assert_renders_greencloth greencloth, html 
    end

    test "code tag inside pre tag" do
      html = "<pre><code>def say_hi\n\tputs 'hi'\nend</code></pre>"
      greencloth = "<pre><code>def say_hi\n\tputs 'hi'\nend</code></pre>"
      assert_renders_greencloth greencloth, html 
    end

    test "code inside list items" do
      html = "<ul><li><code>foo</code></li><li><code>bar</code></li><li>and <code>x</code> is also.</li></ul>"
      greencloth = "* @foo@\n* @bar@\n* and @x@ is also.\n"
      assert_renders_greencloth greencloth, html 
    end

    test "code tag not inside a pre and without new lines inside" do
      html = "<code>some code inside</code>"
      greencloth = "@some code inside@"
      assert_renders_greencloth greencloth, html 
    end
  end

  # embed and object
  # the elements pass trough but the order of the attributes change
  context "embed and object" do
    test "embed" do
      html       = "<p>do you like my embedded blip.tv <embed src='http://blip.tv/play/Ac3GfI+2HA' allowfullscreen='true' type='application/x-shockwave-flash' allowscriptaccess='always' height='510' width='720' />?</p>"
      greencloth = "do you like my embedded blip.tv <embed allowfullscreen=\"true\" src=\"http://blip.tv/play/Ac3GfI+2HA\" allowscriptaccess=\"always\" type=\"application/x-shockwave-flash\" height=\"510\" width=\"720\" />?\n"
      assert_renders_greencloth greencloth, html 
    end

    test "object" do
      html = "<p>do you like my embedded youtube <object width='425' height='344'><param name='movie' value='http://www.youtube.com/v/suvDQoXA-TA&hl=en&fs=1' /><param name='allowFullScreen' value='true' /><embed src='http://www.youtube.com/v/suvDQoXA-TA&hl=en&fs=1' type='application/x-shockwave-flash' width='425' height='344' allowfullscreen='true' /></object>?</p>"
      greencloth = "do you like my embedded youtube <object height=\"344\" width=\"425\"><param name=\"movie\" value=\"http://www.youtube.com/v/suvDQoXA-TA&hl=en&fs=1\" /><param name=\"allowFullScreen\" value=\"true\" /><embed allowfullscreen=\"true\" src=\"http://www.youtube.com/v/suvDQoXA-TA&hl=en&fs=1\" type=\"application/x-shockwave-flash\" height=\"344\" width=\"425\" /></object>?\n"
      assert_renders_greencloth greencloth, html 
    end
  end

  # outline
  # don't allow link to anchors or anchor defs inside hx, greencloth -> html
  # take cares of it, so we are only allowing links inside hx elements for now
  context "outline" do
    test "table of contents toc" do
      html = "<ul class='toc'><li class='toc1'><a href='#fruits'><span>1</span> Fruits</a></li><ul><li class='toc2'><a href='#tasty-apples'><span>1.1</span> Tasty Apples</a></li><ul><li class='toc3'><a href='green'><span>1.1.1</span> Green</a></li><li class='toc3'><a href='#red'><span>1.1.2</span> Red</a></li></ul>"
      greencloth = "[[toc]]\n"
      assert_renders_greencloth greencloth, html 
    end

    test "headings with links, anchors and links to anchors" do
      html = "<h1 class='first'><a name='russian-anarchists'></a>Russian Anarchists<a class='anchor' href='#russian-anarchists'>&para;</a></h1><h2><a name='michel-bakunin'></a>Michel <a href='http://en.wikipedia.org/wiki/Mikhail_Bakunin'>Bakunin</a><a class='anchor' href='#michel-bakunin'>&para;</a></h2><h2><a name='peter-kropotkin'></a><a href='http://en.wikipedia.org/wiki/Peter_Kropotkin'>Peter</a> Kropotkin<a class='anchor' href='#peter-kropotkin'>&para;</a></h2><h1><a name='russian-american-anarchists'></a>Russian-American Anarchists<a class='anchor' href='#russian-american-anarchists'>&para;</a></h1><h2><a name='emma-goldman'></a><a href='http://en.wikipedia.org/wiki/Emma_Goldman'>Emma Goldman</a><a class='anchor' href='#emma-goldman'>&para;</a></h2><h2><a name='alexander-berkman'></a>Alexander <a href='http://en.wikipedia.org/wiki/Alexander_Berkman'>Berkman</a><a class='anchor' href='#alexander-berkman'>&para;</a></h2>"      
      greencloth = "Russian Anarchists\n==================\n\nMichel [Bakunin -> http://en.wikipedia.org/wiki/Mikhail_Bakunin]\n--------------\n\n[Peter -> http://en.wikipedia.org/wiki/Peter_Kropotkin] Kropotkin\n---------------\n\nRussian-American Anarchists\n===========================\n\n[Emma Goldman -> http://en.wikipedia.org/wiki/Emma_Goldman]\n------------\n\nAlexander [Berkman -> http://en.wikipedia.org/wiki/Alexander_Berkman]\n-----------------\n"
      assert_renders_greencloth greencloth, html
    end

    test "double trouble" do
      html = "<h1 class='first'><a name='title'></a>Title<a class='anchor' href='#title'>&para;</a></h1><h3><a name='under-first'></a>Under first<a class='anchor' href='#under-first'>&para;</a></h3><h1><a name='title_2'></a>Title<a class='anchor' href='#title_2'>&para;</a></h1><h3><a name='under-second'></a>Under second<a class='anchor' href='#under-second'>&para;</a></h3>"
      greencloth = "Title\n=====\n\nh3. Under first\n\nTitle\n=====\n\nh3. Under second\n"
      assert_renders_greencloth greencloth, html
    end
  end

  # basics
  context "basics" do
    test "headers" do
      html = "<h1 class='first'>header one</h1>\n<h2>header two</h2>"
      greencloth = "header one\n==========\n\nheader two\n----------\n"
      assert_renders_greencloth greencloth, html 
    end

    test "headers with paragraph" do
      html = "<p>la la la</p>\n<h1 class='first'>header one</h1>\n<h2>header two</h2>\n<p>la la la</p>"
      greencloth = "la la la\n\nheader one\n==========\n\nheader two\n----------\n\nla la la\n"
      assert_renders_greencloth greencloth, html 
    end
  end

  # sections
  # allways we render h1 with ==== and h2 with ----
  context "Convert sections" do
    test "one section no heading" do 
      html = "<div class='wiki_section' id='wiki_section-0'><p>start unheaded section</p><p>line line line</p></div>"
      greencloth = "start unheaded section\n\nline line line\n"
      assert_renders_greencloth greencloth, html 
    end

    test "one section with heading" do
      html = "<div class='wiki_section' id='wiki_section-0'><h2 class='first'>are you ready?!!?</h2><p>here we go now!</p></div>"
      greencloth = "are you ready?!!?\n-----------------\n\nhere we go now!\n"
      assert_renders_greencloth greencloth, html 
    end

    test "all headings" do
      html = "<h1>First</h1><h2>Second</h2><h3>Tres</h3><h4>Cuatro</h4><h5>Five</h5><h6>Six</h6>"
      greencloth = "First\n=====\n\nSecond\n------\n\nh3. Tres\n\nh4. Cuatro\n\nh5. Five\n\nh6. Six\n"
      assert_renders_greencloth greencloth, html 
    end

    test "multiple sections with text" do
      html = "<div class='wiki_section' id='wiki_section-0'><h2 class='first'>Section One</h2><p>section one line one is here<br />section one line two is next</p><p>Here is section one still</p></div><div class='wiki_section' id='wiki_section-1'><h1>Section Two</h1><p>Section two first line<br />Section two another line</p></div><div class='wiki_section' id='wiki_section-2'><h2>Section 3 with h2</h2><p>One more line for section 3</p></div><div class='wiki_section' id='wiki_section-3'><h3>final section 4</h3><p>section 4 first non-blank line</p>\n</div>"
      greencloth = "Section One\n-----------\n\nsection one line one is here\nsection one line two is next\n\nHere is section one still\n\nSection Two\n===========\n\nSection two first line\nSection two another line\n\nSection 3 with h2\n-----------------\n\nOne more line for section 3\n\nh3. final section 4\n\nsection 4 first non-blank line\n"
      assert_renders_greencloth greencloth, html 
    end
  end

  # lists
  # TODO: start attribute not implemented
  context "Converting html lists to greencloth" do
    test "hard break in list" do
      html = "<ul>\n\t<li>first line</li>\n\t<li>second<br />\n\tline</li>\n\t<li>third line</li>\n</ul>\n"
      greencloth = "* first line\n* second\nline\n* third line\n" 
      assert_renders_greencloth greencloth, html 
    end

    test "mixed nesting" do
      html = "<ul><li>bullet\n<ol>\n<li>number</li>\n<li>number\n<ul>\n\t<li>bullet</li>\n</ul></li>\n<li>number</li>\n<li>number with<br />a break</li>\n</ol></li>\n<li>bullet\n<ul><li>okay</li></ul></li></ul>"
      greencloth = "* bullet\n*# number\n*# number\n*#* bullet\n*# number\n*# number with\na break\n* bullet\n** okay\n"
      assert_renders_greencloth greencloth, html 
    end

    test "list continuation" do # uses start
      html = "<ol><li>one</li><li>two</li><li>three</li></ol><ol><li>one</li><li>two</li><li>three</li></ol><ol start='4'><li>four</li><li>five</li><li>six</li></ol>"
      greencloth = "# one\n# two\n# three\n\n# one\n# two\n# three\n\n# four\n# five\n# six\n"
      assert_renders_greencloth greencloth, html 
    end

    test "continue after break" do # uses start
      html = "<ol><li>one</li><li>two</li><li>three</li></ol><p>test</p><ol><li>one</li><li>two</li><li>three</li></ol><p>test</p><ol start='4'><li>four</li><li>five</li><li>six</li></ol>"
      greencloth = "# one\n# two\n# three\n\ntest\n\n# one\n# two\n# three\n\ntest\n\n# four\n# five\n# six\n"
      assert_renders_greencloth greencloth, html 
    end

    test "continue list when prior list contained nested list" do # uses start
      greencloth = "# one\n# two\n# three\n\n# four\n# five\n## sub-note\n## another sub-note\n# six\n\n# seven\n# eight\n# nine\n"
      html = "<ol><li>one</li><li>two</li><li>three</li></ol><ol start='4'><li>four</li><li>five<ol><li>sub-note</li><li>another sub-note</li></ol></li><li>six</li></ol><ol start='7'><li>seven</li><li>eight</li><li>nine</li></ol>"
      assert_renders_greencloth greencloth, html 
    end

    test "" do

    end
  end

  # links
  context "Converting html links to greencloth" do
    test "simple link test" do
      html = "<a href='url'>text</a>"
      greencloth = "[text]"
      assert_not_renders_greencloth greencloth,html
    end

    test "convert a link to a wiki page inside a paragraph" do
      html = "<p>this is a <a href='/page/plain-link'>plain link</a> in some text</p>"
      greencloth = "this is a [plain link] in some text\n"
      assert_renders_greencloth greencloth, html 
    end

    test "convert a link to a wiki page with namespace" do
      html= "<p>this is a <a href='/namespaced/link'>link</a> in some text</p>"
      greencloth = "this is a [namespaced / link] in some text\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "convert a link to a wiki page" do
      html= "<p>this is a <a href='/page/something-else'>link to</a> in some text</p>"
      greencloth = "this is a [link to -> something else] in some text\n"
      assert_renders_greencloth greencloth, html 
    end

    test "convert a link to a wiki page with namespace and text different than link dest" do
      html= "<p>this is a <a href='/namespace/something-else'>link to</a> in some text</p>"
      greencloth = "this is a [link to -> namespace / something else] in some text\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "convert a link to an absolute path" do
      html = "<p>this is a <a href='/an/absolute/path'>link to</a> in some text</p>"
      greencloth = "this is a [link to -> /an/absolute/path] in some text\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "convert a link to an external domain" do
      html = "<p>this is a <a href='https://riseup.net'>link to</a> a url</p>"
      greencloth = "this is a [link to -> https://riseup.net] a url\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "a link to an external domain with the same text as dest" do
      html = "<p>url in brackets <a href='https://riseup.net/'>riseup.net</a></p>"
      greencloth = "url in brackets [riseup.net -> https://riseup.net/]\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "a link to a wiki page with the same name as dest" do
      html = "<p>a <a href='/page/name-link'>name link</a> in need of humanizing</p>"
      greencloth = "a [name link] in need of humanizing\n"
      assert_renders_greencloth greencloth, html 
    end

    test "link to a user blue" do
      html = "<p>link to a user <a href='/blue'>blue</a></p>"
      greencloth = "link to a user [blue]\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "link with dashes should keep the dashes" do
      html = "<p><a href='/-dashes/in/the/link-'>link to</a></p>"
      greencloth = "[link to -> /-dashes/in/the/link-]\n"
      assert_renders_greencloth greencloth, html 
    end

    test "link with underscores should keep the underscores" do
      html = "<p>links <a href='/page/with_underscores'>with_underscores</a> should keep underscore</p>"
      greencloth = "links [with_underscores] should keep underscore\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "a link inside a li element" do
      html ="<ul>\n<li>\n\t\t\n<a href='/page/this'>link to</a></li></ul>"
      greencloth = "* [link to -> this]\n"
      assert_renders_greencloth greencloth, html 
    end

    test "an external link inside a li element" do
      html = "<ul>\n<li><a href='https://riseup.net/'>riseup.net</a></li>\n</ul>"
      greencloth = "* [riseup.net -> https://riseup.net/]\n"
      assert_renders_greencloth greencloth, html 
    end

    test "many anchors inside a paragraph" do
      html = "<p>make anchors <a name='here'>here</a> or <a name='maybe-here'>maybe here</a> or <a name='there'>over</a></p>"
      greencloth = "make anchors [# here #] or [# maybe here #] or [# over -> there #]\n"
      assert_renders_greencloth greencloth, html 
    end

    # TODO: there are differents in this test about how cg support writing anchors
    # this is a reduced support of it
    test "anchors and links" do
      html = "<p>link to <a href='/page/anchors#like-so'>anchors</a> or <a href='/page/like#so'>maybe</a> or <a href='#so'>just</a> or <a href='#so'>so</a></p>"
      greencloth = "link to [anchors -> anchors#like so] or [maybe -> like#so] or [just -> #so] or [so -> #so]\n"
      assert_renders_greencloth greencloth, html 
    end

    test "more anchors" do
      html = "<p><a href='#5'>link</a> to a numeric anchor <a name='5'>5</a></p>"
      greencloth = "[link -> #5] to a numeric anchor [# 5 #]\n"
      assert_renders_greencloth greencloth, html 
    end

    test "3 links without /" do
      html = "<p><a href='some'>some</a> and <a href='other'>other</a> and <a href='one_more'>one_more</a></p>"
      greencloth = "[some] and [other] and [one_more]\n"
      assert_renders_greencloth greencloth, html 
    end
  end

  context "troubles with headings" do
    test "with h1" do
      html = "<h1 class='first'><a name='this-is-h1-text---this-is-h1-text'></a><span class='caps'>THIS</span> IS H1 <span class='caps'>TEXT</span> - this is h1 text<a class='anchor' href='#this-is-h1-text---this-is-h1-text'>¶</a></h1>"
      greencloth = "THIS IS H1 TEXT - this is h1 text\n=================================\n"
      assert_renders_greencloth greencloth, html
    end
  end
end
