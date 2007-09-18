module ProfileHelper

  def photo(profile)
    avatar_for(profile.entity, 'xlarge')
  end

  def random_dom_id
    rand(10**10)
  end
  
  def remove_link(dom_id)
    "<span class='remove'>%s</span>" % link_to_function('remove', "Element.remove($('#{dom_id}'))")
  end    
  
  def add_row_link(title,action)
    link_to_remote title, :url => {:action => action}
  end
  
  
  # set the clicked star in a 'radio-button'-like group to selected
  # sets a hidden field with the value of true/false
  def mark_as_primary(object, object_name, method_name, index)
=begin
    content = ''

    id              = "#{object_name}_#{method_name}_#{index}_preferred"
    name            = "#{object_name}[#{method_name.pluralize}][#{index}][preferred]"
    collection_name = "#{object_name}_#{method_name.pluralize}" # the stars must be in a tbody with this id

    if object.preferred?
      content << "<div id='#{id + '_div'}' title='Currently marked as primary' class='primaryItem'>"
      content << "<input type='hidden' value='true' id='#{id}' name='#{name}' />"
      content << "</div>"
    else
      content << "<div id='#{id + '_div'}' title='Mark as primary' class='makePrimaryItem'>"
      content << "<input type='hidden' value='false' id='#{id}' name='#{name}' />"
      content << "</div>"
    end
    content << javascript_tag("Event.observe('#{id + '_div'}', 'click', function(event){People.markAsPrimary('#{id + '_div'}', '#{collection_name}');});")

    content
=end
  end
  
  def option_array(types)
    types.collect{|a| [a.t, a] }
  end
  
  def select_tag_with_id(name, option_tags = nil, options = {})
    tag_id = options.has_key?(:id) ? options[:id] : name
    content_tag :select, option_tags, { "name" => name, "id" => tag_id }.update(options.stringify_keys)
  end

end

