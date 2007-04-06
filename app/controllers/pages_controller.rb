# controller for managing abstract pages.
# the display and editing of a particular page are handled
# by the controllers in the pages directory

class PagesController < ApplicationController
  
  def new
    return @page = Page.new(params[:page]) if request.get?
    begin
      @page = create_new_page
      if @page.save
        redirect_to page_url(@page)
      else
        message :object => @page
      end
    rescue Exception => exc
      message :error => exc.to_s
    end
  end
  
  def create_new_page
    groups    = get_groups
    users     = get_users
    page_type = get_page_type
    users_to_add = users
    
    page = page_type.new params[:page].merge({:created_by_id => current_user.id})
    groups.each do |group|
      page.add(group, :access => ACCESS_ADMIN)
      users_to_add += group.users if params[:announce] and group.users.any?
    end
    users_to_add.uniq.each do |u|
      if users.include? u
        page.add(u, :access => ACCESS_ADMIN)
      else
        page.add(u)
      end
    end
    page.tag_with(params[:tag_list])
    page
  end

  # add group or user to participations
  def add
    @page = Page.find_by_id(params[:id])
    group = Group.find_by_name(params[:name])
    user = User.find_by_login(params[:name])
    access = params[:access] || ACCESS_ADMIN
    if group
      @page.add group, :access => access
      @page.save
    elsif user
      @page.add user, :access => access
      @page.save
    else
      message :error => 'group or user not found', :later => 1    
    end
    redirect_to page_url(@page)
  end
  
  
  def add_tags
    @page = Page.find_by_id(params[:id])
    tags = Tag.parse(params[:new_tags]) + @page.tags.collect{|t|t.name}
    @page.tag_with(tags.uniq.join(' '))
    @page.save 
    redirect_to page_url(@page)
  end
  
  def tag
    return unless request.xhr? 
    @page = Page.find_by_id(params[:id])
    tags = Tag.parse(params[:tag_list])
    @page.tag_with(tags.uniq.join(' '))
    @page.save
    render :partial => "pages/tags"
    
  end
  
  def search
    if logged_in?
      options = options_for_pages_viewable_by(current_user)
    else
      options = options_for_public_pages
    end
    options.merge!( {:class => Page, :path => params[:path]} )
    @pages, @page_sections = find_and_paginate_pages(options)
  end
  
  # for quickly creating a wiki
  def create_wiki
    group = Group.find_by_name(params[:group])
    if logged_in? and current_user.member_of?(group)
      page = Page.make :wiki, {:user => current_user, :group => group, :name => params[:name]}
      page.save
      redirect_to page_url(page)
    else
      message :error => 'You are not allowed to create a page for group %s' % group.name
    end
  end
  
  protected
  
  def get_groups
    if params[:group_name].any?
      group = Group.find_by_name params[:group_name]
      raise Exception.new('no such group %s' % params[:group_name]) if group.nil?
      [group]
    elsif params[:group_id].any?
      group = Group.find_by_id params[:group_id]
      raise Exception.new('no such group') if group.nil?
      [group]
    else
      []
    end
  end
  
  def get_users
    [current_user]    
  end
  
  def get_page_type
    raise Exception.new('page type required') unless params['page_type']
    return get_tool_class(params['page_type'])
  end
  
end
