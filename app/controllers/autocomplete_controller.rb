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
    render :json => {
      :query => params[:query],
      :suggestions => recipients.collect{|entity|display_on_two_lines(entity)},
      :data => recipients.collect{|r|r.avatar_id||0}
    }
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
    render :json => {
      :query => params[:query],
      :suggestions => recipients.collect{|entity|display_on_two_lines(entity)},
      :data => recipients.collect{|r|r.avatar_id||0}
    }
  end

  private

  # this should be in a helper somewhere, but i don't know how to generate
  # json response in the view.
  def display_on_two_lines(entity)
    "<em>%s</em>%s" % [entity.name, ('<br/>' + h(entity.display_name) if entity.display_name != entity.name)]
  end

end
