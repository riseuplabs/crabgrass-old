#
# Handles the population of autocomplete results for various autocomplete fields
#
# TODO: currently, this is something of a security hole.
# TODO: currently, we do not search for committees by their short name.
#
class AutocompleteController < ApplicationController
  verify :xhr => true

  def entities
    # check if we are preloading...
    if params[:query] == ""
      recipients = current_user.groups
      recipients += User.friends_of(current_user)
    else
      filter = "#{params[:query]}%"
      if current_user.group_ids.any?
        recipients = Group.find(:all,
          :conditions => ["(groups.name LIKE ? OR groups.full_name LIKE ? ) AND
            NOT groups.id IN (?)",
            filter, filter, current_user.group_ids],
          :limit => 20)
      else
        recipients = Group.find(:all,
          :conditions => ["(groups.name LIKE ? OR groups.full_name LIKE ? )",
            filter, filter],
          :limit => 20)
      end
      recipients += User.on(current_site).strangers_to(current_user).find(:all,
        :conditions => ["users.login LIKE ? OR users.display_name LIKE ?", filter, filter],
        :limit => 20)
      recipients = recipients.sort_by{|r|r.name}[0..19]
    end


    render_entities_to_json(recipients)
  end

  def people
    if params[:query] == ""
      recipients = User.friends_of(current_user)
    else
      filter = "#{params[:query]}%"
      recipients = User.on(current_site).strangers_to(current_user).find(:all,
        :conditions => ["users.login LIKE ? OR users.display_name LIKE ?", filter, filter],
        :limit => 20)
    end

    render_entities_to_json(recipients)
  end

  def friends
    if params[:query] == ""
      friends = User.friends_of(current_user)
    else
      # already preloaded
      friends = []
    end

    render_entities_to_json(friends)
  end

  # recipients for direct messages from current user
  def recipients
    if params[:query] == ""
      recipients = User.friends_of(current_user)
      recipients +=  current_user.peers
    else
      # already preloaded
      recipients = []
    end

    render_entities_to_json(recipients)
  end


  # senders of direct messages to current user
  def senders
    if params[:query] == ""
      senders = current_user.discussions.with_some_posts.collect {|discussion| discussion.user_talking_to(current_user)}
    else
      # already preloaded
      senders = []
    end

    render_entities_to_json(senders)
  end

  def locations
    return if params[:query] == ""
    filter = "#{params[:query]}%"
    locations = GeoPlace.find(:all, :conditions => ["name LIKE ?", filter], :limit => 20)
    render_locations_to_json(locations)
  end

  private

  def render_entities_to_json(entities)
    render :json => {
      :query => params[:query],
      :suggestions => entities.collect{|e|display_on_two_lines(e.display_name, h(e.name))}
      :data => entities.collect{|e|e.avatar_id||0}
    }
  end

  def render_locations_to_json(locations)
    render :json => {
      :query => params[:query],
      :suggestions => locations.collect{|loc|display_on_two_lines(loc.name, loc.geo_admin_code.name)}
    }
  end


  # this should be in a helper somewhere, but i don't know how to generate
  # json response in the view.
  def display_on_two_lines(first, second)
    "<em>%s</em>%s" % [first, ('<br/>' + second if second != first)]
    #"<em>%s</em>%s" % [entity.display_name, ('<br/>' + h(entity.name) if entity.display_name != entity.name)]
  end

end
