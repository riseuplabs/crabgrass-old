class MeController < ApplicationController

  append_before_filter :fetch_user
  
  def index
    params[:path] = []
    folder()
  end

  def folder
    options = {
      :class => UserParticipation,
      :path => params[:path],
      :conditions => 'user_participations.user_id = ?',
      :values => [current_user.id]
    }
    @pages, @page_sections = find_and_paginate_pages page_query_from_filter_path(options)
    render :action => 'index'
  end

 
  def edit   
    if request.post? 
      if @user.update_attributes(params[:user])
        redirect_to :action => 'edit'
      else
        message :object => @user
      end
    end
  end

  #def avatar
  #  if request.post?
  #    avatar = Avatar.create(:data => params[:image][:data])
  #    if avatar.valid?
  #      @user.avatar.destroy if @user.avatar
  #      @user.avatar = avatar
  #      @user.save
  #      redirect_to :action => 'edit'
  #      return
  #    end
  #  end
  #  render :action => 'edit'
  #end
  
  protected
  
  def fetch_user
    @user = current_user
  end
  
  def breadcrumbs
    add_crumb 'me', me_url(:action => 'index')
    unless ['show','index'].include?(params[:action])
      add_crumb params[:action], me_url(:action => params[:action])
    end
  end
end
