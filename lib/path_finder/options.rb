=begin

to be included in the Application class so that all controllers have access
to these methods.

=end

module PathFinder::Options

  private
   
  def default_find_options
    options = { :controller => get_controller }
    if logged_in?
      options.merge :user_id => current_user.id, :group_ids => current_user.all_group_ids
    else
      options[:public] = true
    end
    options
  end

  # this module might be included in helpers and it might be included
  # in controllers. either way, we want to know what the controller is.
  def get_controller
    if self.is_a? ActionController::Base
      return self
    else
      return self.controller
    end
  end
    
  public
  
  # all the pages that I have access to
  # include public pages only if args includes :public
  def options_for_me(args={})
    # options for sphinx come from default_find_options
    
    # options for sql
    if args[:public]
      options = {
        :conditions => "(group_parts.group_id IN (?) OR user_parts.user_id = ? OR pages.public = ?)",
        :values     => [current_user.all_group_ids, current_user.id, true]
      }
      return default_find_options.merge(options).merge(args)
    else
      lambda {|parsed_path|
        if parsed_path.keyword?('group') or parsed_path.keyword?('person')
          # if person or group is in the path, then we must do a query
          # that joins on both the group_participations table and the user_participations
          # table.
          options = {
            :conditions => "(group_parts.group_id IN (?) OR user_parts.user_id = ?)",
            :values     => [current_user.all_group_ids, current_user.id]
          }
          default_find_options.merge(options).merge(args)
        else
          # since there is no person or group in the path, we can use a union, which is
          # much faster.
          query1 = {
            :conditions => "group_parts.group_id IN (?)",
            :values     => [current_user.all_group_ids]
          }
          query2 = {
            :conditions => "user_parts.user_id = ?",
            :values     => [current_user.id]
          }
          options = {:union => [query1, query2]}
          default_find_options.merge(options).merge(args)
        end
      } # end lambda
    end
  end
  
  def options_for_inbox(args={})
    options = {
      :conditions => 'user_participations.user_id = ? AND user_participations.inbox = ?',
      :values => [current_user.id, true],
      :inbox => true
    }
    default_find_options.merge(options).merge(args)
  end
  
  def options_for_public_pages
    options = {
      :public => true,
      :conditions => "(pages.public = ?)",
      :values     => [true] }
    default_find_options.merge(options)
  end
  
  def options_for_participation_by(user, args={})
  
    # options for sphinx
    options = { :public => true, :other_user_id => user.id }
    
    # options for sql
    if logged_in?
      # the person's pages that we also have access to
      options[:conditions] = "user_participations.user_id = ? AND (group_parts.group_id IN (?) OR user_parts.user_id = ? OR pages.public = ?)"
      options[:values]     = [user.id, current_user.all_group_ids, current_user.id, true]
    else
      # the person's public pages
      options[:conditions] = "user_participations.user_id = ? AND pages.public = ?"
      options[:values]     = [user.id, true]
    end
    default_find_options.merge(options).merge(args)
  end

  def options_for_group(group, args={})
    group_id = group.is_a?(Group) ? group.id : group.to_i
    
    # options for sphinx
    options = { :public => true, :group_id => group_id }

    # options for sql
    if logged_in?
      # the group's pages that current_user also has access to
      # this means: the group must have a group participation and one of the following
      # must be true... the page is public, we have a user participation for it, or a group
      # that we are a member of has a group participation for the page.
      options[:conditions] = "(group_participations.group_id = ? AND (group_parts.group_id IN (?) OR user_parts.user_id = ? OR pages.public = ?))"
      options[:values]     = [group_id, current_user.all_group_ids, current_user.id, true]
    else
      # the group's public pages
      options[:conditions] = "group_participations.group_id = ? AND pages.public = ?"
      options[:values]     = [group_id, true]
    end
    
    default_find_options.merge(options).merge(args)
  end

  #########################################
  ## path management utilities
  
  def build_filter_path(search)
    PathFinder::Builder.build_filter_path(search)
  end

  def parse_filter_path(path)
    PathFinder::Builder.parse_filter_path(path)
  end

end
