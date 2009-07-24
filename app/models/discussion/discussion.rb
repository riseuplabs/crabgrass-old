#
#  create_table "discussions", :force => true do |t|
#    t.integer  "posts_count",      :limit => 11, :default => 0
#    t.datetime "replied_at"
#    t.integer  "replied_by_id",    :limit => 11
#    t.integer  "last_post_id",     :limit => 11
#    t.integer  "page_id",          :limit => 11
#    t.integer  "commentable_id",   :limit => 11
#    t.string   "commentable_type"
#  end
#  add_index "discussions", ["page_id"], :name => "index_discussions_page_id"
#
class Discussion < ActiveRecord::Base

  ##
  ## associations
  ##

  belongs_to :page
  belongs_to :replied_by, :class_name => 'User'
  belongs_to :last_post, :class_name => 'Post'

  # i think this is currently unused?
  has_one :profile, :foreign_key => 'discussion_id'

  has_many :posts, :order => 'posts.created_at', :dependent => :destroy, :class_name => 'Post'

  belongs_to :commentable, :polymorphic => true

  # if we are a private discussion:
  has_many :relationships do
    def contact_of(user)
      self.select {|relationship| return relationship.contact if relationship.user_id == user.id}
    end
    def for_user(user)
      self.select {|relationship| return relationship if relationship.user_id == user.id}
    end
  end

  ##
  ## PRIVATE DISCUSSION
  ##

  def last_post_by(user)
    self.posts.find_by_user_id(user.id, :order => 'created_at DESC')
  end

  #def unread_count(user)
  #  if relationship = self.relationships.for_user(user)
  #    self.posts.count :conditions => ['created_at > ?', relationship.viewed_at]
  #  else
  #    0
  #  end
  #end

  def increment_unread_for(user)
    relationships.for_user(user).try.increment!(:unread_count)
  end

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
