require "hpricot"
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

  # if this array is empty we allow all tags
  # if the processed node name not exist in this array we drop it
  ALLOWED_TAGS = []

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
      (@doc/"ul|ol").each do |list|
        fixup_list(list) if list.parent != "li" && list.parent.name !~ /ul|ol/
      end

      (@doc/"p|span").each do |e|
        fixup_span_with_styles(e)
      end
    end

    # Delete tabs, newlines and more than 2 spaces from inside elements
    # except <pre> or <code> elements
    def cleanup_indentation
      (@doc/"*").each do |e|
        if e.elem? && e.inner_html != "" && e.name !~ (/pre|code/) && e.children.size == 0
          e.inner_html = e.inner_html.gsub(/\n|\t/,"").gsub(/\s+/," ")
        elsif e.text? && e.parent.name !~ /pre|code/
          e.content = e.content.gsub(/\n|\t/,"").gsub(/\s+/," ")
          e.content = e.content.gsub(/^\s+$/, "") if e.next_node && e.next_node.name != "span"
        end
      end
    end

    # For those elements like <span> if they are used to represent bold, italic
    # such as those used on wysiwyg editors, we remove that after convert to not
    # use them on the final convertion.
    def fixup_span_with_styles(e)
        return if !e.has_attribute?("style")

        if e["style"] =~ /italic/        then e.inner_html = "<em>#{e.inner_html}</em>"          end
        if e["style"] =~ /underline/     then e.inner_html = "<ins>#{e.inner_html}</ins>"        end
        if e["style"] =~ /line-through/  then e.inner_html = "<del>#{e.inner_html}</del>"        end
        if e["style"] =~ /bold/          then e.inner_html = "<strong>#{e.inner_html}</strong>"  end
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
  end

  module ::Hpricot #:nodoc:
    class Elem #:nodoc:
      def ancestors
        node, ancestors = parent, Elements[]
        while node.respond_to?(:parent) && node.parent
          ancestors << node
          node = node.parent
        end
        ancestors
      end
    end
  end
end
