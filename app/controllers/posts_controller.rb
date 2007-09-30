class PostsController < ApplicationController

  before_filter :login_required
  
  def create    
    begin
      @page = Page.find params[:page_id]
      current_user.may!(:comment, @page)
      @post = Post.new params[:post]
      @page.build_post(@post,current_user)
      @post.save!
      current_user.updated(@page)
      respond_to do |wants|
        wants.html {
          redirect_to page_url(@page)#, :anchor => @page.discussion.posts.last.dom_id)
          # :paging => params[:paging] || '1')
        }
        wants.xml {
          render :xml => @post.to_xml, :status => 500
        }
      end
      return
    rescue ActiveRecord::RecordInvalid
      msg = @post.errors.full_messages.to_s
    rescue PermissionDenied
      msg = 'you do not have permission to do that'
    end
    flash[:bad_reply] = msg
    respond_to do |wants|
      wants.html {
        redirect_to page_url(@page, :anchor => 'reply-form')
        #, :paging => params[:paging] || '1')
      }
      wants.xml {
        render :xml => msg, :status => 400
      }
    end
  end
 
  def edit
  end
  
  def save
    if params[:save]
      @post.update_attribute('body', params[:body])
    elsif params[:destroy]
      @post.destroy
      return(render :action => 'destroy')
    end
  end
  
  def twinkle   
    @post.ratings.find_or_create_by_user_id(current_user.id).update_attribute(:rating, 1)
  end

  def untwinkle
    if rating = @post.ratings.find_by_user_id(current_user.id)
      rating.destroy
    end
  end

  protected
    
  def authorized?
    @post = Post.find(params[:id]) if params[:id]
    return true unless @post

    if %w[twinkle untwinkle].include? params[:action]
      return current_user.may?(:comment, @post.discussion.page)
    else
      return current_user.id == @post.user_id
    end
  end

end

