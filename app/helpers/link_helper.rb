module LinkHelper
  
  def submit_button(label,form_id,options={})
    options = {:class => 'button'}.merge options
    accesskey = shortcut_key label
    onclick = %Q<submit_form("#{form_id}", "#{label}")>
    onclick = %Q<if(confirm("#{options[:confirm]}")){submit_form("#{form_id}", "#{label}");}else{return false;}> if options[:confirm]
    %Q(<span class="button"><a href='#' onclick='#{onclick}' style='#{options[:style]}' class='#{options[:class]}' accesskey='#{accesskey}'>#{label}</a></span>)
  end
    
  def link_button(label,options={},htmloptions={})
    accesskey = shortcut_key label
    url = url_for options
    aclass = htmloptions[:class]
    %Q[<span class="button"><a href='#{url}' class='button #{aclass}' accesskey='#{accesskey}'>#{label}</a></span>]
  end
    
  def post_button(label,options={},html_options={})
    accesskey = shortcut_key label
    a = link_to(label, options, {:post => true, :class=>'button', :accesskey=>accesskey}.merge(html_options) )
    "<span class='button'>#{a}</span>"
  end
    
  def shortcut_key(label)
    label.gsub!(/\[(.)\]/, '<u>\1</u>')
    /<u>(.)<\/u>/.match(label).to_a[1]
  end
    
  def link_show_hide(showlabel, hidelabel, element)
    %Q[<a href="javascript:void(0);" onclick="toggleLink(this,'#{hidelabel}');Element.toggle($('#{element}'));return false;">#{showlabel}</a>]
  end  
  
  def post_to(label, options={}, html_options={})
    accesskey = shortcut_key label
    link_to(label, options, {:post => true, :accesskey=>accesskey}.merge(html_options))
  end
  
end