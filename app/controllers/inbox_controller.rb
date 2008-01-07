class InboxController < ApplicationController
 
  before_filter :login_required
 
  layout 'me'

  def index
    if request.post?
      update
    else
      path = params[:path]
      path = ['starred','or','unread','or','pending'] if path.first == 'vital'
      path << 'descending' << 'updated_at'
      @pages, @sections = Page.find_and_paginate_by_path(path, options_for_inbox)
      add_user_participations(@pages)
      handle_rss  :title => 'Crabgrass Inbox', :link => '/me/inbox',
                 :image => avatar_url(:id => @user.avatar_id||0, :size => 'huge')
    end
  end

  # post required
  def update
    if params[:remove] 
      remove
    else
      ## add more actions here later
    end
  end

  # post required
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
  
  # given an array of pages, find the corresponding user_participation records
  # and associate each participtions with the correct page.
  # afterwards, page.flag[:user_participation] should hold current_user's
  # participation for page.
  def add_user_participations(pages)
    pages_by_id = {}
    pages.each{|page|pages_by_id[page.id] = page}
    uparts = UserParticipation.find(:all, :conditions => ['user_id = ? AND page_id IN (?)',current_user.id,pages_by_id.keys])
    uparts.each do |part|
      pages_by_id[part.page_id].flag[:user_participation] = part
    end
  end
  
end
