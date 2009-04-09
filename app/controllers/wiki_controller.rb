=begin

 WikiController

 This is the controller for the in-place wiki editor, not for the
 the wiki page type (wiki_page_controller.rb).

 Everything here is entirely ajax, for now.

=end

class WikiController < ApplicationController
  
  include ControllerExtension::WikiRenderer
  
  before_filter :login_required, :except => [:show]
  
  # show the rendered wiki
  def show
    @wiki.render_html{|body| render_wiki_html(body, @group.name)}
  end
  
  # show the entire edit form
  def edit
    @private.lock(Time.now, current_user)
    @public.lock(Time.now, current_user)
  end
  
  # a re-edit called from preview, just one area.
  def edit_area
    return render(:action => 'done') if params[:close]
  end
  
  # save the wiki show the preview
  def save
    return render(:action => 'done') if params[:cancel]
    begin
      @wiki.smart_save!(:body => params[:body], 
        :user => current_user, :version => params[:version])
      @wiki.unlock if @wiki.locked_by?(current_user)
      @wiki.render_html{|body| render_wiki_html(body, @group.name)}
    rescue Exception => exc
      @message = exc.to_s
      return render(:action => 'error')
    end    
  end
  
  # unlock everything and show the rendered wiki
  def done
    @private.unlock if @private.locked_by?(current_user)
    @public.unlock if @public.locked_by?(current_user)
    
    if @private.body.nil? or @private.body == ''
      @wiki = @public
    else
      @wiki = @private
    end
  end

  protected
  
  def authorized?
    
    # common objects used by most actions
    @group = Group.find(params[:group_id])
    @profile = @group.profiles.find(params[:profile_id])
    @public = @group.profiles.public.wiki || @group.profiles.public.create_wiki
    @private = @group.profiles.private.wiki || @group.profiles.private.create_wiki
    
    # some actions are keyed on either the private or public wiki.
    if params[:access] == 'private'
      @wiki = @private
    elsif params[:access] == 'public'
      @wiki = @public
    end
    
    logged_in? and current_user.member_of?(@group)
  end    
  
end
