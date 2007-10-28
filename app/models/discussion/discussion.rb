class Discussion < ActiveRecord::Base

  ## associations ###########################################
  
  belongs_to :page
    
  # relationship with posts   
  has_many :posts, :order => 'posts.created_at', :dependent => :destroy do
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
 
  # don't know why i can't get posts_count to be correct value
  # for now, we use posts.count
  def paged?() posts.count > per_page end
  
  def last_page
    (posts.count.to_f / per_page.to_f).ceil.to_i
  end

#  def editable_by?(user)
#    user && (user.id == user_id || user.admin? || user.moderator_of?(forum_id))
#  end
  
end
