class GroupsController < ApplicationController

  def authorized?
    if action?(:create)
      @parent=get_parent
      current_user.may?(:admin, current_site) or @parent
    else
      true
    end
  end
end
