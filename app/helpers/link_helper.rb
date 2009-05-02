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
# 
# Creating get requests
# ---------------------
# 
# link_to (built-in)
# this is the built in function for links, no change here.
#
# button_to (built-in)
# pass method get to options.
# eg. button_to('label', {:action => 'xxx', :method => 'get'}, {:class => 'whatever'})
#  
#
# Creating post requests
# ------------------------
# 
# button_to (built in)
# creates a button that creates a post request.
#
# link_to (built-in)
# pass with html_options {:method => 'post'}
# eg: link_to 'destroy', {:action => 'destroy'}, {:method => 'post'}
#
#
# Creating ajax requests
# -----------------------
#
# link_to_remote (built in)
# 
# remote_form_for + submit_tag (built in)
#
# button_to_remote (not yet written)
# would work like link_to_remote, but would create a button 
# (by using remote_form_for and submit_tag)
#
module LinkHelper
  
  ### SUBMITS ###

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
  
  ### AJAX ###
 
  # def button_to_remote()
  #  to be written
  # end 
  
  ### UTIL ###
  
  def shortcut_key(label)
    label.gsub!(/\[(.)\]/, '<u>\1</u>')
    /<u>(.)<\/u>/.match(label).to_a[1]
  end
  
  # just like link_to, but sets the <a> tag to have class 'active'
  # if last argument is true or if the url is in the form of a hash
  # and the current params match this hash.
  def link_to_active(link_label, url_hash, active=nil)
    active = url_active?(url_hash) || active  # yes this is weird, but we want url_active? to always get called.
    selected_class = active ? 'active' : ''
    link_to(link_label,url_hash, :class => selected_class)
  end

  def url_active?(url_hash)
    return false unless url_hash.is_a? Hash

    if params[:controller] && params[:controller] !~ /^\//
      params[:controller] = '/' + params[:controller]
    end
    if url_hash[:controller] && url_hash[:controller] !~ /^\//
      url_hash[:controller] = '/' + url_hash[:controller] unless url_hash[:controller] =~ /^\//
    end
  
    url_hash[:action] = 'index' if url_hash[:action].nil?

    selected = url_hash.inject(true) do |selected, p|
      param, value = p
      selected and params[param].to_s == value.to_s
    end

    return selected
  end

end
