class Discussion < ActiveRecord::Base

  ## associations ###########################################
  
  belongs_to :page
    
  # relationship with posts   
  has_many :posts, :order => 'posts.created_at', :dependent => :destroy, :class_name => '::Post' do
    def last
      @last_post ||= find(:first, :order => 'posts.created_at desc')
    end
  end

   
  ## attributes ############################################# 

  # to help with the create form
  attr_accessor :body  

  ## validations ############################################



  ## callbacks ##############################################

  before_create { |r| r.replied_at = Time.now.utc }
#  after_save    { |r| Post.update_all ['forum_id = ?', r.forum_id], ['topic_id = ?', r.id] }

  ## methods ################################################
  
  def per_page() 20 end
 
  # this doesn't appear to be called anywhere.
  def paged?() posts_count > per_page end
  
  def last_page
    if posts_count > 0
      (posts_count.to_f / per_page.to_f).ceil
    else
      1
    end
  end

#  def editable_by?(user)
#    user && (user.id == user_id || user.admin? || user.moderator_of?(forum_id))
#  end
  
end
