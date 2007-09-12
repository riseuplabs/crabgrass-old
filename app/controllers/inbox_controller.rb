class InboxController < ApplicationController
  layout 'me'

  def handle_rss
    if params[:path].any? and (params[:path].last == 'rss' or params[:path].last == '.rss')
      response.headers['Content-Type'] = 'application/rss+xml'
#      @items = find_pages(options_for_group(@group),'/descending/updated_at/limit/10')
      @title ||= 'Crabgrass Inbox'
      @link ||= '/me/inbox'
      @image ||= @user.avatar
      render :partial => '/pages/rss', :locals => {:items => @pages}
    end
  end
      
  def index
    if request.post?
      update
    else
      path = params[:path]
      path = ['starred','or','unread','or','pending'] if path.first == 'vital'
      options = {
        :class => UserParticipation,
        :path => path,
        :conditions => 'user_participations.user_id = ?',
        :values => [current_user.id]
      }
      @pages, @sections = find_and_paginate_pages(options)

      handle_rss
    end
  end

  def update
    if params[:remove] 
      remove
    else
      ## add more actions here later
    end
  end

  def remove
    to_remove = params[:page_checked]
    if to_remove
      to_remove.each do |page_id, do_it|
        if do_it == 'checked' and page_id
          page = Page.find_by_id(page_id)
          if page
            upart = page.participation_for_user(@user)
            upart.destroy
          end
        end
      end
    end
    redirect_to url_for(:controller => 'inbox', :action => 'index', :path => params[:path]) 
  end
  
  protected
  
  append_before_filter :fetch_user
  def fetch_user
    @user = current_user
  end
  
  # always have access to self
  def authorized?
    return true
  end
  
  def context
    me_context('large')
    add_context 'inbox'.t, url_for(:controller => 'inbox', :action => 'index')
  end
  
end
