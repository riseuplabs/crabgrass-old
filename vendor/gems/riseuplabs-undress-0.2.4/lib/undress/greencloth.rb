require File.expand_path(File.dirname(__FILE__) + "/textile")

module Undress
  class GreenCloth < Textile
    whitelist_attributes :style, :colspan, :rowspan, :bgcolor, :align
    whitelist_styles :"background-color", :background, :"text-align", :"text-decoration",
      :"font-weight", :color

    Undress::ALLOWED_TAGS = [
      'div', 'a', 'img', 'br', 'i', 'u', 'b', 'pre', 'kbd', 'code', 'cite', 'strong', 'em',
      'ins', 'sup', 'sub', 'del', 'table', 'tbody', 'thead', 'tr', 'td', 'th', 'ol', 'ul',
      'li', 'p', 'span', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'notextile', 'blockquote',
      'object', 'embed', 'param', 'acronym', 'dd', 'dl', 'dt', 'font'
    ]

    Undress::NO_TEXT_TAGS = %w(img br table tbody thead tr ol ul)

    # table of contents
    pre_processing("ul.toc") do |toc|
      toc.swap "[[toc]]\n"
    end

    # headings
    rule_for(:h1, :h2, :h3, :h4, :h5, :h6) {|e| process_headings(e) }

    # inline elements
    rule_for(:a) {|e|
      "#{process_links_and_anchors(e)}"
    }

    # lists
    rule_for(:li) {|e|
      offset = ""
      li = e
      # start is not whitelisted so we access it directly
      if li.parent.name == 'ol' and li.previous_sibling.nil?
        start = li.parent.has_attribute?("start") && li.parent["start"]
      end
      while li.parent
        if    li.parent.name == "ul" then offset = "*#{offset}"
        elsif li.parent.name == "ol" then offset = "##{offset}"
        else  return "\n#{offset}#{start} #{content_of(e)}"
        end
        li = li.parent.parent ? li.parent.parent : nil
      end
      "\n#{offset}#{start} #{content_of(e)}"
    }

    # text formatting
    rule_for(:pre) {|e|
      if e.children && e.children.all? {|n| n.text? && n.content =~ /^\s+$/ || n.elem? && n.name == "code" }
        "\n\n<code>#{unescaped_content_of(e % "code")}</code>"
      else
        "\n\n<pre>#{unescaped_content_of(e)}</pre>"
      end
    }

    rule_for(:code) {|e|
      if e.inner_html.match(/\n/)
          "<code>#{unescaped_content_of(e)}</code>"
      else
        "@#{unescaped_content_of(e)}@"
      end
    }

    # passing trough objects
    rule_for(:embed, :object, :param) {|e|
      e.to_html
    }

    def unescaped_content_of(e)
      e.children.map { |x| x.to_plain_text }.join
    end

    def process_headings(h)
      h.children.each {|e|
        next if e.class == Hpricot::Text
        e.parent.replace_child(e, "") if e.has_attribute?("href") && e["href"] !~ /^\/|(https?|s?ftp):\/\//
      }
      case h.name
        when "h1"
          "#{content_of(h)}\n#{'=' * h.inner_text.size}\n\n" if h.name == "h1"
        when "h2"
          "#{content_of(h)}\n#{'-' * h.inner_text.size}\n\n" if h.name == "h2"
        else
          "#{h.name}. #{content_of(h)}\n\n"
      end
    end

    def process_links_and_anchors(e)
      if e.empty?
        ""
      elsif anchor_outside_headings?(e)
        process_anchor(e)
      elsif not (e.get_attribute("href").nil? || e.get_attribute("href") == '')
        process_link(e)
      else
        ""
      end
    end

    def anchor_outside_headings?(e)
      e.get_attribute("name") and
      e.parent.is_a?(Hpricot::Doc) || !e.parent.name.match(/^h1|2|3|4|5|6$/)
    end

    def process_anchor(e)
      inner, name = content_of(e), e.get_attribute("name")
      inner == name || inner == name.gsub(/-/,"\s") ?
        "[# #{inner} #]" :
        "[# #{inner} -> #{name} #]"
    end

    def process_link(e)
      # title = e.has_attribute?("title") ? " (#{e["title"]})" : ""
      # return "#{content_of(e)}#{title}:#{e["href"]}"
      inner, href = content_of(e), e.get_attribute("href")
      case href
      when /^\/?#/
        link_syntax(inner,href)
      when /^[^\/]/
        link_syntax(inner,href)
      when /^\/.[^\/]*\/.[^\/]*\//
        link_syntax(inner,href)
      when /(?:\/page\/\+)[0-9]+$/
        link_syntax(inner, "+#{href.gsub(/\+[0-9]+$/)}]")
      else
        process_as_wiki_link(e)
      end
    end

    def link_syntax(inner,href)
      return "[#href]" if inner == href
      return "[#{href}]" if href.gsub(/^(https?|s?ftp):\/\//, "") == inner
      inner=quote_if_needed(inner)
      "#{inner}:#{href}"
    end

    # TODO: actually check if we have an image not just the !
    def quote_if_needed(inner)
      if inner[0] == '!' and inner[-1] == '!'
        inner
      else
        '"' + inner + '"'
      end
    end

    def process_as_wiki_link(e)
      inner, name, href = content_of(e), e.get_attribute("name"), e.get_attribute("href")

      # pages or group pages
      context_name, page_name = href.split("/")[1..2]
      page_name = context_name if page_name.nil?
      wiki_page_name = page_name.gsub(/[a-z-]*[^\/]$/m) {|m| m.tr('-',' ')}

      # simple page
      if context_name == "page"
        return "[#{inner}]" if wiki_page_name == inner
        return "[#{inner} -> #{wiki_page_name}]"
      end
      # group page
      if context_name != page_name
        return "[#{context_name} / #{wiki_page_name}]" if wiki_page_name == inner
        return "[#{inner} -> #{wiki_page_name}]" if context_name == "page"
        return "[#{inner} -> #{context_name} / #{wiki_page_name}]"
      end
      if inner == page_name || inner == wiki_page_name || inner == wiki_page_name.gsub(/\s/,"-")
        return "[#{wiki_page_name}]"
      end
      # fall back
      return "[#{inner} -> #{href}]"
    end

  end
  add_markup :greencloth, GreenCloth
end
