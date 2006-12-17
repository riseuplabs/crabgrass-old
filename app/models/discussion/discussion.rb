require 'page'

class Discussion < ActiveRecord::Base

  ## associations ###########################################
  
  belongs_to :page
  
  # this is really a has_one
  #has_many :pages, :as => :tool
  #def page() pages.first; end
  
  # disabled has_many_polymorph stuff:
  ## relationship with parent page
  ## has_many :pages
  ## ^^^ auto created by has_many_polymorph in Page
  
  # relationship with posts   
  has_many :posts, :order => 'posts.created_at', :dependent => :destroy do
    def last
      @last_post ||= find(:first, :order => 'posts.created_at desc')
    end
  end

  #belongs_to :replied_by_user, :foreign_key => "replied_by", :class_name => "User"
  
  ## attributes ############################################# 

  # to help with the create form
  attr_accessor :body  

  ## validations ############################################



  ## callbacks ##############################################

  before_create { |r| r.replied_at = Time.now.utc }
#  after_save    { |r| Post.update_all ['forum_id = ?', r.forum_id], ['topic_id = ?', r.id] }

  ## methods ################################################
  
#  def voices
#    posts.map { |p| p.user_id }.uniq.size
#  end
  
#  def paged?() posts_count > 25 end
  
  def last_page
    (posts_count.to_f / 25.0).ceil.to_i
  end

#  def editable_by?(user)
#    user && (user.id == user_id || user.admin? || user.moderator_of?(forum_id))
#  end
  
end
