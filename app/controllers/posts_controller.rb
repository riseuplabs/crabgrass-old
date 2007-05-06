class PostsController < ApplicationController

  def create    
    begin
      @page = Page.find params[:page_id]
      current_user.may!(:participate, @page)      
      @discussion = @page.discussion ||= Discussion.create
      @post       = @discussion.posts.build(params[:post])
      @post.user  = current_user
      @post.save!
      current_user.updated(@page)
      respond_to do |wants|
        wants.html {
          @user = current_user # helps page_url
          redirect_to page_url(@page, :anchor => @post.dom_id)
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
  
  def destroy
  end
  
  def authorized?
    @post = Post.find(params[:id]) if params[:id]
    if @post 
      return current_user == @post.user
    else
      return true
    end
  end
    

end

