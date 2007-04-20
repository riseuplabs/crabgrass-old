class PeopleController < ApplicationController
  model :user

  verify :method => :post,
    :only => [ :add_contact, :remove_contact],
    :redirect_to => { :action => :list }

  prepend_before_filter :fetch_user
  
  def index
    list
    render :action => 'list'
  end

  def list
   # @user_pages, @users = paginate :users, :per_page => 10
    @contacts = current_user.contacts
    @peers = current_user.peers
  end

  def show
    params[:path] = []
    folder()
  end

  def folder
    options = {:class => UserParticipation, :path => params[:path]}
    if logged_in?
      # pages the user as contributed to and that we also have access to
      options[:conditions] = "user_participations.user_id = ? " +
                             "AND user_participations.changed_at IS NOT ? " + 
                             "AND (group_parts.group_id IN (?) OR user_parts.user_id = ? OR pages.public = ?)"
      options[:values]     = [@user.id, nil, current_user.group_ids, current_user.id, true]
    else
      # public pages the user has contributed to
      options[:conditions] = "pages.public = ? " + 
                             "AND user_participations.user_id = ? " + 
                             "AND user_participations.changed_at IS NOT ?"
      options[:values]     = [@user.id, true, nil]
    end
    @pages, @page_sections = find_and_paginate_pages page_query_from_filter_path(options)
    render :action => 'show'
  end

  def tasks
    @stylesheet = 'tasks'
    options = options_for_page_participation_by(@user)
    options[:path] = ['type','task']
    @pages = find_pages(options)
    @task_lists = @pages.collect{|p|p.data}
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    if request.post? 
      @user.update_attributes(params[:user])
      groups = params[:name].split(/[,\s]/)
      for group in groups
        @new_group = Group.find(:all, :conditions =>["name = ?",group])
        @user.groups << @new_group unless @user.groups.find_by_name group
        if @new_group.nil?
          flash[:notice] = 'Group %s does not exist.' %group
        end
      end
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'show', :id => @user
    end
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'show', :id => @user
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to :action => 'list'
  end
  
  # post only
  def add_contact
    page = Page.make :request_for_contact, :user => current_user, :contact => @user
    if page.save
      message :success => 'Your contact request has been sent to %s.' / @user.login
      page = Page.make :contact_sent_notice, :user => current_user, :contact => @user
      page.save
      redirect_to person_url(:action => 'show', :id => @user)
    else
      message :object => page
      render :action => 'show'
    end
  end
  
  # post only  
  def remove_contact
    current_user.contacts.delete(@user)
    message :success => '%s has been removed from your contact list.' / @user.login
    redirect_to :action => 'show', :id => @user
  end
  
  def new_message
    page = Page.make :private_message, :from => current_user, :to => @user
    if page.save
      redirect_to page_url(page)
    else
      message :object => page
      render :action => 'show'
    end
  end
  
  protected
  
  def breadcrumbs
    add_crumb 'people', people_url(:action => 'index')
    add_crumb @user.login, people_url(:id => @user, :action => 'show') if @user
    unless ['show','index','list'].include? params[:action]
      add_crumb params[:action], people_url(:action => params[:action], :id => @user)
    end
    if @user
      set_banner 'people/banner_large', @user.style
    end
  end
  
  def fetch_user 
    @user = User.find_by_login params[:id]
    @is_contact = current_user.contacts.include?(@user)
    true
  end
  
end
