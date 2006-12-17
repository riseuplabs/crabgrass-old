
class PagesController < ApplicationController

  in_place_edit_for :page, :title
  
  def view
    @page = Page.find params[:id]
    #update_last_seen_at
    #(session[:topics] ||= {})[@topic.id] = Time.now.utc if logged_in?
    
    @page.discussion = Discussion.new unless @page.discussion
    @post_pages, @posts = paginate(:posts, :per_page => 25, :order => 'posts.created_at',
       :include => :user, :conditions => ['posts.discussion_id = ?', @page.discussion.id])
    @post = Post.new
  end



  
end
