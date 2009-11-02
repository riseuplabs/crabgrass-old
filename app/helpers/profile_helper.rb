module ProfileHelper

  def photo(profile)
    avatar_for(profile.entity, 'xlarge')
  end

  def random_dom_id
    rand(10**10)
  end

  def remove_link(dom_id)
    "<span class='remove'>%s</span>" % link_to_function(I18n.t(:remove), "Element.remove($('#{dom_id}'))")
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

  def select_tag_with_id(name, option_tags = nil, options = {})
    tag_id = options.has_key?(:id) ? options[:id] : name
    content_tag :select, option_tags, { "name" => name, "id" => tag_id }.update(options.stringify_keys)
  end

  def location_line(profile)
    loc = profile.locations.first
    "<div class='small_icon world_16'><em>#{I18n.t(:location)}</em>: #{loc.city.capitalize}, #{loc.country_name.capitalize}</div>"
  end

  #def birthday_line(profile)
  #  "TODO (birthday_line)"#"<div class='small_icon date_16'><em>#{I18n.t(:I18n)(:year_of_birth)} </em>: #{profile.birthday.year}</div>"
  #end

  #def interest_line(profile)
  #  "<div class='small_icon heart_16'><em>(TODO)Interest </em>: Family, Travel, Music, Politics, Outdoors,   Friends</div>"
  #end

  def member_since_line(profile)
    "<div class='small_icon status_online_16'><em>#{I18n.t(:profile_member_since)}</em>: #{friendly_date(profile.user.created_at)}</div>"
  end

  def last_login(user)
    "%s: %s"  % [I18n.t(:profile_last_login), friendly_date(user.last_seen_at)]
  end

  def profile_description
    if @profile.public?
      I18n.t(:profile_public_description)
    elsif @profile.private?
      I18n.t(:profile_private_description)
    end + ' ' + content_tag(:strong, link_to(I18n.t(:preview)+ARROW, '/'+current_user.login+'?profile='+@profile.type))
  end
end

