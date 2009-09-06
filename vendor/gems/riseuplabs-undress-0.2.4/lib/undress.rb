require File.expand_path(File.dirname(__FILE__) + "/hpricot_ext")
require File.expand_path(File.dirname(__FILE__) + "/core_ext/object")
require File.expand_path(File.dirname(__FILE__) + "/undress/grammar")

# Load an HTML document so you can undress it. Pass it either a string or an IO
# object. You can pass an optional hash of options, which will be forwarded
# straight to Hpricot. Check it's
# documentation[http://code.whytheluckystiff.net/doc/hpricot] for details.
def Undress(html, options={})
  Undress::Document.new(html, options)
end

module Undress

  INLINE_ELEMENTS = ['span', 'b', 'strong', 'i', 'em', 'ins', 'del','strike', 'abbr', 'acronym', 'cite', 'code', 'label', 'sub', 'sup']

  # Register a markup language. The name will become the method used to convert
  # HTML to this markup language: for example registering the name +:textile+
  # gives you <tt>Undress(code).to_textile</tt>, registering +:markdown+ would
  # give you <tt>Undress(code).to_markdown</tt>, etc.
  def self.add_markup(name, grammar)
    Document.add_markup(name, grammar)
  end

  class Document #:nodoc:
    def initialize(html, options)
      @doc = Hpricot(html, options)
      xhtmlize!
      cleanup_indentation
    end

    def self.add_markup(name, grammar)
      define_method "to_#{name}" do
        grammar.process!(@doc)
      end
    end

    private
    
    # We try to fix those elements which aren't write as xhtml standard but more
    # important we can't parse it ok without correct it before.
    def xhtmlize!
      (@doc/"ul|ol").each   {|list| fixup_list(list) if list.parent != "li" && list.parent.name !~ /ul|ol/}
      (@doc/"p|span").each  {|e| fixup_span_with_styles(e)}
      (@doc/"strike").each  {|e| e.change_tag! "del"}
      (@doc/"u").each       {|e| e.change_tag! "ins"}
      (@doc/"td|th").each   {|e| fixup_cells(e)}
    end

    # Delete tabs, newlines and more than 2 spaces from inside elements
    # except <pre> or <code> elements
    def cleanup_indentation
      (@doc/"*").each do |e| 
        if e.elem? && e.inner_html != "" && e.name !~ (/pre|code/) && e.children.size == 0 
          e.inner_html = e.inner_html.gsub(/\n|\t/,"").gsub(/\s+/," ")
        elsif e.text? && e.parent.name !~ /pre|code/
          e.content = e.content.gsub(/\n|\t/,"").gsub(/\s+/," ")
          e.content = e.content.gsub(/^\s+$/, "") if e.next_node && ! INLINE_ELEMENTS.include?(e.next_node.name)
        end
      end
    end

    # For those elements like <span> if they are used to represent bold, italic
    # such as those used on wysiwyg editors, we remove that after convert to not
    # use them on the final convertion.
    def fixup_span_with_styles(e)
      return if !e.has_attribute?("style")

      if e.get_style("font-style") == "italic"
        e.inner_html = "<em>#{e.inner_html}</em>"
        e.del_style("font-style")
      end

      if e.get_style("text-decoration") == "underline"
        e.inner_html = "<ins>#{e.inner_html}</ins>"
        e.del_style("text-decoration")
      end

      if e.get_style("text-decoration") == "line-through"
        e.inner_html = "<del>#{e.inner_html}</del>"
        e.del_style("text-decoration")
      end

      if e.get_style("font-weight") == "bold"
        e.inner_html = "<strong>#{e.inner_html}</strong>"
        e.del_style("font-weight")
      end

      e.swap e.inner_html if e.styles.empty? && e.name == "span"
    end

    # Fixup a badly nested list such as <ul> sibling to <li> instead inside of <li>.
    def fixup_list(list)
      list.children.each {|e| fixup_list(e) if e.elem? && e.name =~ /ol|ul/}

      if list.parent.name != "li"
        li_side = list.next_sibling     if list.next_sibling     && list.next_sibling.name     == "li"
        li_side = list.previous_sibling if list.previous_sibling && list.previous_sibling.name == "li"

        if li_side
          li_side.inner_html = "#{li_side.inner_html}#{list.to_html}"
          list.parent.replace_child(list, "")
        end
      end
    end
  
    # spaces beetween td and th elements break textile formatting
    # <br> aren't allowed
    # strip spaces
    def fixup_cells(e)
      e.search("br").remove
      e.next_node.content = "" if e.next_node && e.next_node.text?
      e.previous_node.content = "" if e.previous_node && e.previous_node.text?
      content = e.inner_html.gsub(/\&nbsp\;/,"\s").strip
      e.inner_html = content == "" ? [] : content
    end
  end
end
