module LinkHelper
  
#  def menu_link_to(text, image, options)
#    selected="not_selected"
#    if @params[:controller] == options[:controller]
#      #      if (options[:select_on] == :controller) or (@params["action"] == options[:action])
#      selected="selected" 
#      #     end
#    end
#    #link_to(image_tag("32/"+image,:border=>0) + "<br/>" + text, { :controller=>options[:controller], :action=>options[:action],:id=>@user }, :class=>selected)
#    link_to(text, { :controller=>options[:controller], :action=>options[:action],:id=>@user }, :class=>selected)
#  end
   
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
  
  
end