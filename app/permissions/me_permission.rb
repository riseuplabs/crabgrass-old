module MePermission
  # always have access to self
  #  def authorized?
  #    return true
  #  end
  def may_edit_me?
    logged_in?
  end

  %w(index counts delete_avatar).each{ |action|
    alias_method "may_#{action}_me?".to_sym, :may_edit_me?
  }

  # Dashboard
  %w(index show_welcome_box close_welcome_box).each{ |action|
    alias_method "may_#{action}_dashboard?".to_sym, :may_edit_me?
  }

  # Inbox 
  %w(search index list update remove).each{ |action|
    alias_method "may_#{action}_inbox?".to_sym, :may_edit_me?
  }

  # Infoviz
  alias_method :may_visualize_infobiz?, :may_edit_me?

  # Requests 
  %w(from_me to_me).each{ |action|
    alias_method "may_#{action}_requests?".to_sym, :may_edit_me?
  }

  # Search
  alias_method :may_index_search?, :may_edit_me?

  # Tasks 
  %w(pending completed).each{ |action|
    alias_method "may_#{action}_tasks?".to_sym, :may_edit_me?
  }

  # Trash 
  %w(search index list update).each{ |action|
    alias_method "may_#{action}_trash?".to_sym, :may_edit_me?
  }

end
