require File.expand_path(File.dirname(__FILE__) + "/../undress")

module Undress
  class Textile < Grammar
    whitelist_attributes :class, :id, :lang, :style, :colspan, :rowspan

    # entities
    post_processing(/&nbsp;/, " ")

    # whitespace handling
    post_processing(/\n\n+/, "\n\n")
    post_processing(/\A\s+/, "")
    post_processing(/\s+\z/, "\n")

    # special characters introduced by textile
    post_processing(/&#8230;/, "...")
    post_processing(/&#8217;/, "'")
    post_processing(/&#822[01];/, '"')
    post_processing(/&#8212;/, "--")
    post_processing(/&#8211;/, "-")
    post_processing(/(\d+\s*)&#215;(\s*\d+)/, '\1x\2')
    post_processing(/&#174;/, "(r)")
    post_processing(/&#169;/, "(c)")
    post_processing(/&#8482;/, "(tm)")

    # inline elements
    rule_for(:a) {|e|
      title = e.has_attribute?("title") ? " (#{e["title"]})" : ""
      "[#{content_of(e)}#{title}:#{e["href"]}]"
    }
    rule_for(:img) {|e|
      alt = e.has_attribute?("alt") && e["alt"]
      alt = "(#{alt})" unless alt == ""
      "!#{e["src"]}#{alt}!"
    }
    rule_for(:strong)  {|e| complete_word?(e) ? "*#{attributes(e)}#{content_of(e)}*" : "[*#{attributes(e)}#{content_of(e)}*]"}
    rule_for(:em)      {|e| complete_word?(e) ? "_#{attributes(e)}#{content_of(e)}_" : "[_#{attributes(e)}#{content_of(e)}_]"}
    rule_for(:code)    {|e| "@#{attributes(e)}#{content_of(e)}@" }
    rule_for(:cite)    {|e| "??#{attributes(e)}#{content_of(e)}??" }
    rule_for(:sup)     {|e| surrounded_by_whitespace?(e) ? "^#{attributes(e)}#{content_of(e)}^" : "[^#{attributes(e)}#{content_of(e)}^]" }
    rule_for(:sub)     {|e| surrounded_by_whitespace?(e) ? "~#{attributes(e)}#{content_of(e)}~" : "[~#{attributes(e)}#{content_of(e)}~]" }
    rule_for(:ins)     {|e| complete_word?(e) ? "+#{attributes(e)}#{content_of(e)}+" : "[+#{attributes(e)}#{content_of(e)}+]"}
    rule_for(:del)     {|e| complete_word?(e) ? "-#{attributes(e)}#{content_of(e)}-" : "[-#{attributes(e)}#{content_of(e)}-]"}
    rule_for(:acronym) {|e| e.has_attribute?("title") ? "#{content_of(e)}(#{e["title"]})" : content_of(e) }


    # text formatting and layout
    rule_for(:p) do |e|
      at = attributes(e) != "" ? "p#{at}#{attributes(e)}. " : ""
      e.parent && e.parent.name == "blockquote" ? "#{at}#{content_of(e)}\n\n" : "\n\n#{at}#{content_of(e)}\n\n"
    end
    rule_for(:br)         {|e| "\n" }
    rule_for(:blockquote) {|e| "\n\nbq#{attributes(e)}. #{content_of(e)}\n\n" }
    rule_for(:pre)        {|e|
      if e.children && e.children.all? {|n| n.text? && n.content =~ /^\s+$/ || n.elem? && n.name == "code" }
        "\n\npc#{attributes(e)}. #{content_of(e % "code")}\n\n"
      else
        "<pre>#{content_of(e)}</pre>"
      end
    }

    # headings
    rule_for(:h1) {|e| "\n\nh1#{attributes(e)}. #{content_of(e)}\n\n" }
    rule_for(:h2) {|e| "\n\nh2#{attributes(e)}. #{content_of(e)}\n\n" }
    rule_for(:h3) {|e| "\n\nh3#{attributes(e)}. #{content_of(e)}\n\n" }
    rule_for(:h4) {|e| "\n\nh4#{attributes(e)}. #{content_of(e)}\n\n" }
    rule_for(:h5) {|e| "\n\nh5#{attributes(e)}. #{content_of(e)}\n\n" }
    rule_for(:h6) {|e| "\n\nh6#{attributes(e)}. #{content_of(e)}\n\n" }

    # lists
    rule_for(:li) {|e|
      token = e.parent.name == "ul" ? "*" : "#"
      nesting = e.ancestors.inject(1) {|total,node| total + (%(ul ol).include?(node.name) ? 0 : 1) }
      "\n#{token * nesting} #{content_of(e)}"
    }
    rule_for(:ul, :ol) {|e|
      if e.ancestors.detect {|node| %(ul ol).include?(node.name) }
        content_of(e)
      else
        "\n#{content_of(e)}\n\n"
      end
    }

    # definition lists
    rule_for(:dl) {|e| "\n\n#{content_of(e)}\n" }
    rule_for(:dt) {|e| "- #{content_of(e)} " }
    rule_for(:dd) {|e| ":= #{content_of(e)} =:\n" }

    # tables
    rule_for(:table)   {|e| "\n#{table_attributes(e)}\n#{content_of(e)}\n" }
    rule_for(:tr)      {|e| "#{row_attributes(e)}#{content_of(e)}|\n" }
    rule_for(:td, :th) {|e| "|#{cell_attributes(e)}#{content_of(e)}" }

    def attributes(node) #:nodoc:
      filtered ||= super(node)
      attribs = ""

      if filtered
        if colspan = filtered.delete(:colspan)
          attribs << "\\#{colspan}"
        end

        if rowspan = filtered.delete(:rowspan)
          attribs << "/#{rowspan}"
        end

        if lang = filtered.delete(:lang)
          attribs << "[#{filtered[:lang]}]"
        end

        if klass = filtered.delete(:class)
          klass.sub!(/(odd|even) ?/, '') if node.name == 'tr'
        end
        id = filtered.delete(:id)
        if (klass && klass != '') or id
          id = id.nil? ? "" : "#" + id
          attribs << "(#{klass}#{id})"
        end

        if style = filtered.delete(:style)
          attribs << "{#{style}}"
        end
      end
      attribs
    end

    def table_attributes(node)
      attributes(node) == "" ? "" : "table#{attributes(node)}. "
    end

    def row_attributes(node)
      attributes(node) == "" ? "" : "#{attributes(node)}. "
    end

    def cell_attributes(node)
      ret = (node.name == 'th') ? "_#{attributes(node)}" : attributes(node)
      return if ret.nil? or ret == ''
      ret[-1] == '.' ? "#{ret} " : "#{ret}. "
    end
  end


  add_markup :textile, Textile
end
