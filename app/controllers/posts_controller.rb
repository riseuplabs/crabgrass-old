class PostsController < ApplicationController

  def create    
    begin
      @page = Page.find params[:page_id]
      current_user.may!(:participate, @page)      
      @discussion = @page.discussion ||= Discussion.create
      @post       = @discussion.posts.build(params[:post])
      @post.user  = current_user
      @post.save!
      respond_to do |wants|
        wants.html {
          redirect_to pagepath(@page, :anchor => @post.dom_id, :paging => params[:paging] || '1')
        }
        wants.xml {
          render :xml => @post.to_xml, :status => 500
        }
      end
      return
    rescue ActiveRecord::RecordInvalid
      msg = @post.errors.to_xml
    rescue InsufficientPermission
      msg = 'you do not have permission to do that'
    end
    flash[:bad_reply] = msg
    respond_to do |wants|
      wants.html {
        redirect_to pagepath(@page, :anchor => 'reply-form', :paging => params[:paging] || '1')
      }
      wants.xml {
        render :xml => msg, :status => 400
      }
    end
  end
 
end
