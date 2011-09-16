# Connectingclassrooms is prioritizing entities differently

class AutocompleteController < ApplicationController
  def entities
    # check if we are preloading...
    if params[:query] == ""
      recipients = Network.all
      recipients += current_user.groups.only_groups
      recipients += User.friends_of(current_user)
    else
      filter = "#{params[:query]}%"
      filtered_groups = Group.without_member(current_user).public.named_like(filter)
      recipients = filtered_groups.only_groups.
        find(:all, :limit => 20).sort_by{|r|r.name}
      recipients += filtered_groups.only_type('Council').
        find(:all, :limit => 20).sort_by{|r|r.name}
      recipients += filtered_groups.only_type('Committee').
        find(:all, :limit => 20).sort_by{|r|r.name}
      users = User.on(current_site).visible_strangers_to(current_user).named_like(filter)
      recipients += users.find(:all, :limit => 20)
      recipients = recipients[0..19]
    end


    render_entities_to_json(recipients)
  end
end
