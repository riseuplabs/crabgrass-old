class PeopleController < ApplicationController
  model :user

  verify :method => :post,
    :only => [ :add_contact, :remove_contact],
    :redirect_to => { :action => :list }

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
    @user = User.find_by_login params[:id]
    @is_contact = current_user.contacts.include?(@user)
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
    @user = User.find(params[:id])
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
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'show', :id => @user
    else
      render :action => 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  # post only
  def add_contact
    contact = User.find_by_login params[:id]
    page = Page.make :request_for_contact, :user => current_user, :contact => contact
    if page.save
      message :success => 'Your contact request has been sent to %s.' / contact.login
      redirect_to person_url(:action => 'show', :id => contact)
    else
      message :object => page
      render :action => 'show'
    end
  end
  
  # post only  
  def remove_contact
    other = User.find_by_login params[:id]
    current_user.contacts.delete(other)
    message :success => '%s has been removed from your contact list.' / other.login
    redirect_to :action => 'show', :id => params[:id]
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
    @user = User.find_by_login(params[:id])
    add_crumb 'people', people_url(:action => 'index')
    add_crumb @user.login, people_url(:id => @user, :action => 'show') if @user
    unless ['show','index','list'].include? params[:action]
      add_crumb params[:action], people_url(:action => params[:action], :id => @user)
    end
  end
end
