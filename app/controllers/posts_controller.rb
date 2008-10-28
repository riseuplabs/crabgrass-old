class PostsController < ApplicationController

  before_filter :login_required
  
  def create    
    begin
      @page = Page.find params[:page_id]
      current_user.may!(:comment, @page)
      @post = Post.build params[:post].merge(:user => current_user, :page => @page)
      @post.save!
      current_user.updated(@page)
      @page.save!
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
    if rating = @post.ratings.find_by_user_id(current_user.id)
      rating.update_attribute(:rating, 1)
    else
      rating = @post.ratings.create(:user_id => current_user.id, :rating => 1)
    end

    # this should be in an observer, but oddly it doesn't work there.
    TwinkledActivity.create!(
      :user => @post.user, :twinkler => current_user, 
      :post => {:id => @post.id, :snippet => @post.body[0..30]}
    )
  end

  def untwinkle
    if rating = @post.ratings.find_by_user_id(current_user.id)
      rating.destroy
    end
  end

  def jump
    redirect_to page_url(@post.discussion.page) + "#posts-#{@post.id}"
  end

  protected
    
  def authorized?
    @post = Post.find(params[:id]) if params[:id]
    return true unless @post

    if %w[twinkle untwinkle].include? params[:action]
      return current_user.may?(:comment, @post.discussion.page)
    else
      return @post.editable_by?(current_user)
    end
  end

end

