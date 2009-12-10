#
# Abstract superclass of all controllers that handle group stuff.
#
class Groups::BaseController < ApplicationController

  stylesheet 'groups'
  helper 'groups'
  permissions 'groups/base'

  protected

  def fetch_group
    if params[:id]
      @group = Group.find_by_name(params[:id])
    end
    true
  end

  def context
    if @group
      group_context
      @left_column = render_to_string(:partial => '/groups/navigation/sidebar')
    end
  end

  def group_settings_context
    @group_navigation = :settings
    group_context
    @left_column = render_to_string(:partial => '/groups/navigation/sidebar')
    add_context(I18n.t(:settings), groups_url(:action => 'edit', :id => @group))
  end

end

