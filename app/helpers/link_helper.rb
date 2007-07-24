module LinkHelper
  
#
# Here lies many helpers for making links and buttons.
#
# Traditionally, all POSTS are done with submit buttons and all
# GETS are done with links. On occasion, we might want to mix it up. 
# These helpers let us do that, and use the accesskey facility in gecko
# browsers.
# 
# Submitting forms
# ----------------
#
# submit_tag
# The normal built in function. do :class => 'button' or :class => 'link' to 
# change how it looks.
# 
# submit_button
# looks like a button, but is a link so that we can add accesskeys.
#
# submit_link
# a link which will submit the form.
#
#
# The multiple submit buttons
# ---------------------------
#
# Normally, when a form is submitted it is simply submitted. Often, we would
# like to be able to have two different submit buttons. Here is how you would 
# do that:
#
#   submit_tag 'Save', :name => 'save'
#   submit_tag 'Cancel', :name => 'cancel'
#
# In the controller, then test for params[:save] or params[:cancel]. The 
# values will be useless (set to 'Save' and 'Cancel' in this case, but it could
# be anything if using translations). Normally, setting :name does not work for
# ajax forms. This is changed with a modification of the default submit_tag
# function. All the submit helpers accept the name parameter.
# 
# Creating get requests
# ---------------------
# 
# link_button
# it looks like a button, but it is just a link that creates a get request.
# 
# link_to
# this is the built in function for links, no change here.
#
# 
# Creating post requests
# 
# post_button
# creates a button that creates a post request.
# 
# post_to
# creates a link that will send a post. This is just the same
# as link_to with :method => 'post'
#
  
  
  ### SUBMITS ###
  
  def submit_button(label, options={})
    submit_link(label, {:class => 'button'}.merge(options))
  end
    
  def submit_link(label, options={})
    name = options.delete(:name) || 'commit'
    value = options.delete(:value) || label
    accesskey = shortcut_key label
    onclick = %Q<submit_form(this, "#{name}", "#{value}");>
    if options[:confirm]
      onclick = %Q<if(confirm("#{options[:confirm]}")){#{onclick};}else{return
 false;}>
    end
    %Q(<span class='#{options[:class]}'><a href='#' onclick='#{onclick}' style
='#{options[:style]}' class='#{options[:class]}' accesskey='#{accesskey}'>#{
label}</a></span>)    
  end

  ### BUTTONS ###
  
  def link_button(label,options={},htmloptions={})
    accesskey = shortcut_key label
    url = url_for options
    aclass = htmloptions[:class]
    %Q[<span class="button"><a href='#{url}' class='button #{aclass}' 
accesskey='#{accesskey}'>#{label}</a></span>]
  end
    
  def post_button(label,options={},html_options={})
    accesskey = shortcut_key label
    a = link_to(label, options, {:post => true, :class=>'button', :accesskey=>
accesskey}.merge(html_options) )
    "<span class='button'>#{a}</span>"
  end
  
  ### AJAX ###
  
  def function_button(label, *args, &block)
    accesskey = shortcut_key label
    args << {:class => 'button', :accesskey=> accesskey}
    link_to_function(label, *args, &block)
  end
  
  ### UTIL ###
  
  def shortcut_key(label)
    label.gsub!(/\[(.)\]/, '<u>\1</u>')
    /<u>(.)<\/u>/.match(label).to_a[1]
  end
    
  def link_show_hide(showlabel, hidelabel, element)
    %Q[<a href="javascript:void(0);" onclick="toggleLink(this,'#{hidelabel}');
Element.toggle($('#{element}'));return false;">#{showlabel}</a>]
  end  
  
  def post_to(label, options={}, html_options={})
    accesskey = shortcut_key label
    link_to(label, options, {:method => :post, :accesskey => accesskey}.merge(
html_options))
  end
  
end
