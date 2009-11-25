require File.expand_path(File.dirname(__FILE__) + "/hpricot_ext.rb")

class UglifyHtml
  def initialize(html, options = {})
    @doc = Hpricot html
    options[:pass_through] ||= []
    @options = options
  end

  def make_ugly
    (@doc/"*").each do |e|
      next if @options[:pass_through].include? e.name
  
      if @options[:rename_tag] and @options[:rename_tag].has_key? e.name
        e.change_tag! @options[:rename_tag][e.name]
        next
      end

      case e.name
      when 'b', 'strong'    then process_with_style(e, "font-weight",      "bold")
      when 'i', 'em'        then process_with_style(e, "font-style",       "italic")
      when 'u', 'ins'       then process_with_style(e, "text-decoration",  "underline")
      when 'del', 'strike'  then process_with_style(e, "text-decoration",  "line-through")
      when 'ul', 'ol'       then process_list(e)
      end 
    end

    (@doc/"li ul | li ol").remove

    html = @doc.to_html

    html = html + "<br/>" if html.match(/<\/table>$/) 

    html
  end

  private

  def process_with_style(e, style, value)
    if e.parent and e.parent.name == "span" and e.parent.children.size == 1
      e.parent.set_style(style, value)
      e.swap e.inner_html
    else
      e.change_tag! "span"
      e.set_style(style, value)
    end
  end

  def process_list(e)
    return if not e.parent or not e.parent.name == "li"
    e.parent.after(e.to_html)
  end
end
