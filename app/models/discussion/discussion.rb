class Discussion < ActiveRecord::Base
 
  ##
  ## associations
  ##

  belongs_to :page
  belongs_to :replied_by, :class_name => 'User'
  belongs_to :last_post, :class_name => 'Post'
  
  has_one :profile, :foreign_key => 'discussion_id'
  has_one :acquaintance, :foreign_key => 'discussion_id'
  has_many :posts, :order => 'posts.created_at', :dependent => :destroy, :class_name => 'Post'

  belongs_to :commentable, :polymorph => true
  
  ## 
  ## attributes
  ##

  # to help with the create form
  #attr_accessor :body  

  #before_create { |r| r.replied_at = Time.now.utc }
  #after_save    { |r| Post.update_all ['forum_id = ?', r.forum_id], ['topic_id = ?', r.id] }

  ##
  ## methods
  ##

  def per_page() 30 end
 
  # this doesn't appear to be called anywhere.
  #def paged?() posts_count > per_page end
  
  def last_page
    if posts_count > 0
      (posts_count.to_f / per_page.to_f).ceil
    else
      1
    end
  end

end
