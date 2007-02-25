# abstract super class of controller for tools

class Tool::BaseController < ApplicationController

  layout 'pages'
  
  protected
  
  def breadcrumbs
    return unless params[:id] and @page = Page.find_by_id(params[:id])
    if params[:from]
      if logged_in? and params[:from] == 'people' and params[:from_id] == current_user.to_param
        add_crumb 'me', me_url
      else
        add_crumb params[:from], url_for(:controller => params[:from])
        if params[:from_id]
          if params[:from] == 'groups'
            group = Group.find_by_id(params[:from_id])
            text = group.name if group
          elsif params[:from] == 'people'
            text = params[:from_id]
          end
          if text
            add_crumb text, url_for(:controller => params[:from], :id => params[:from_id], :action => 'show')
          end
        end
      end
    elsif @page
      # figure out the first group or first user, and use that for breadcrumb.
      if @page.groups.any?
        add_crumb 'groups', groups_url
        group = @page.groups.first
        add_crumb group.name, groups_url(:action => 'show', :id => group)
      elsif @page.created_by
        add_crumb 'people', people_url
        user = @page.created_by
        add_crumb user.login, people_url(:action => 'show', :id => user)
      end
    end
    # this is silly
    add_crumb @page.title, request.request_uri #temporarily commented out. jb.
  end
  



end
