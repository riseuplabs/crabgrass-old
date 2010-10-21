#
# Abstract superclass of all controllers that handle group stuff.
#

class Groups::BaseController < ApplicationController

  stylesheet 'groups'
  helper 'groups', 'locations'
  permissions 'groups/base', 'groups/requests', 'groups/memberships'
  before_filter :fetch_group

  protected

  def fetch_group
    @group ||= Group.find_by_name(params[:group_id] || params[:id])
    true
  end

  def context
    @context = Context::Group.new(@group)
  end

end

