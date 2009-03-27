# = PathFinder::Options
#
# This module should be included in the Application class 
# so that all controllers have access to these methods.
#
# They are used as options for find_by_path in PathFinder::FindByPath
#
# The corresponding callbacks are in PathFinder::Mysql::Options,
# PathFinder::Sphinx::Options and PathFinder::Sql::Options.

module PathFinder::Options

  # access options for pages current_user has access to
  def options_for_me(args={})
    default_options.merge(
      :callback => :options_for_me
    ).merge(args)
  end

  # access options for all public pages (only)
  def options_for_public(args={})
    default_options.merge(
      :callback => :options_for_public
    ).merge(args)
  end

  # access options for pages in my inbox
  def options_for_inbox(args={})
    default_options.merge(
      :callback => :options_for_inbox,
      :method => :sql
    ).merge(args)
  end

  # access options for pages I have access to
  # and that +group+ has participated in.
  def options_for_group(group,args={})
    default_options.merge(
      :callback => :options_for_group,
      :callback_arg_group => group
    ).merge(args)
  end

  # access options for pages I have access to
  # and that +group+ has participated in.
  def options_for_groups(groups,args={})
    default_options.merge(
      :callback => :options_for_groups,
      :callback_arg_groups => groups
    ).merge(args)
  end

  # access options for pages I have access to
  # and that +user+ has participated in.
  def options_for_user(user,args={})
    default_options.merge(
      :callback => :options_for_user,
      :callback_arg_user => user
    ).merge(args)
  end

  # contructs a path from a set of search params
  def build_filter_path(search)
    PathFinder::ParsedPath.new(search).to_path
  end

  # builds a parsed path from a text path.
  def parse_filter_path(path)
    PathFinder::ParsedPath.new(path)
  end

  private
  
  def default_options   # :nodoc:
    options = {
      :controller => get_controller,
      :public => false,
    }
    if logged_in?
      # TODO:
      # this does not work for sites yet. Problems are:
      # * we would need current_site.all_group_ids - including committees
      # options[:group_ids] = current_site.network.nil? ?
      #  current_user.all_group_ids :
      #  current_user.all_group_ids # & current_site.group_ids
      # --
      #   ^^^ THERE IS A MUCH BETTER WAY TO DO THIS. -elijah
      #       basically, what is needed is a complex intersect between
      #       the site, the user's groups, and the pages groups. this is best
      #       handled using a fulltext index on the access_ids field. 
      options[:user_ids] = [current_user.id]
      options[:group_ids] = current_user.all_group_ids
      options[:current_user] = current_user
    else
      options[:public] = true
      # options[:group_ids] = current_site.group_ids unless current_site.network.nil?
    end
    options
  end

  # this module might be included in helpers and it might be included
  # in controllers. either way, we want to know what the controller is.
  def get_controller   # :nodoc:
    if self.is_a? ActionController::Base
      return self
    else
      return self.controller
    end
  end

end
