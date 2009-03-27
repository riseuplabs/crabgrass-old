# =PathFinder::Sql::Options
#
# Callback functions for PathFinder::Options in case of a plain Sql backend.
#
# The callback functions populate the arrays with query parts for options.
# They are called from resolve_options in PathFinder::FindByPath
#
# We are currently only using Mysql.
module PathFinder::Sql::Options

  def self.options_for_me(path, options)
    currentuser = options[:current_user]
    if options[:public]
      ops = {
        :conditions => "(group_parts.group_id IN (?) OR user_parts.user_id = ? OR pages.public = ?)",
        :values     => [currentuser.all_group_ids, currentuser.id, true]
      }
    else
      if path.keyword?('group') or path.keyword?('person')
        # if person or group is in the path, then we must do a query
        # that joins on both the group_participations table and the user_participations
        # table.
        ops = {
          :conditions => "(group_parts.group_id IN (?) OR user_parts.user_id = ?)",
          :values     => [currentuser.all_group_ids, currentuser.id]
        }
      else
        # since there is no person or group in the path, we can use a union, which is
        # much faster.
        query1 = {
          :conditions => "group_parts.group_id IN (?)",
          :values     => [currentuser.all_group_ids]
        }
        query2 = {
          :conditions => "user_parts.user_id = ?",
          :values     => [currentuser.id]
        }
        ops = {:union => [query1, query2]}
      end
    end
    return options.merge(ops)
  end

  def self.options_for_inbox(path, options)
    options.merge({
      :conditions => 'user_participations.user_id = ? AND user_participations.inbox = ?',
      :values => [options[:current_user].id, true],
      :inbox => true
    })
  end
  
  def self.options_for_public(path, options)
    options.merge({
      :conditions => "(pages.public = ?)",
      :values     => [true]
    })
  end
  
  def self.options_for_user(path, options)
    user = options[:callback_arg_user]
    user_id = user.is_a?(User) ? user.id : user.to_i

    if options[:current_user]
      # the person's pages that we also have access to
      options[:conditions] = "user_participations.user_id = ? AND (group_parts.group_id IN (?) OR user_parts.user_id = ? OR pages.public = ?)"
      options[:values]     = [user_id, options[:current_user].all_group_ids, options[:current_user].id, true]
    else
      # the person's public pages
      options[:conditions] = "user_participations.user_id = ? AND pages.public = ?"
      options[:values]     = [user_id, true]
    end
    options
  end

  def self.options_for_group(path, options)
    group = options[:callback_arg_group]
    group_id = group.is_a?(Group) ? group.id : group.to_i
    
    if options[:current_user]
      # the group's pages that current_user also has access to
      # this means: the group must have a group participation and one of the following
      # must be true... the page is public, we have a user participation for it, or a group
      # that we are a member of has a group participation for the page.
      options[:conditions] = "(group_participations.group_id = ? AND (group_parts.group_id IN (?) OR user_parts.user_id = ? OR pages.public = ?))"
      options[:values]     = [group_id, options[:current_user].all_group_ids, options[:current_user].id, true]
    else
      # the group's public pages
      options[:conditions] = "group_participations.group_id = ? AND pages.public = ?"
      options[:values]     = [group_id, true]
    end
    options
  end

end
