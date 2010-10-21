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

  has_many :visible_posts, :order => 'posts.created_at', :class_name => 'Post', :conditions => {:deleted_at => nil}

  belongs_to :commentable, :polymorphic => true

  # if we are a private discussion (or 'messages')
  has_many :relationships do
    def for_user(user)
      self.detect {|relationship| relationship.user_id == user.id}
    end
  end

  ##
  ## NAMED SCOPES
  ##

  named_scope :with_some_posts, :conditions => ['discussions.posts_count > ?', 0]


  # used when relationships are joined in
  # ex: current_user.discussions.from_user(User.first)
  # where user has many dicussions through relationships
  named_scope :from_user, lambda { |user|
    user.blank? ? {} : { :conditions => ['relationships.contact_id = ?', user.id] }
  }

  # user with relationships like the above scope
  # ex: current_user.discussions.unread
  named_scope :unread, :conditions => ['relationships.unread_count > 0']
  named_scope :all # used same as :unread, but with nothing to filter

  ##
  ## PRIVATE DISCUSSION (MESSAGES)
  ##

  # this discussion is between 2 people
  # takes one user, returns the other
  def user_talking_to(user)
    relationship_to_other_user = self.relationships.for_user(user)
    relationship_to_other_user.try.contact
  end


  # each pair of users (if they are contacts)
  # shares a discussion. a single user has a list of discussions, one per friend.
  # the user's discussions list is sorted by the time the last thing was said on each discussion
  # most recently updated discussions are first on the list.
  #
  # @current_discussion.next_for(current_user) returns the next discussion in that list
  def next_for(user)
    all_discussions = user.discussions.with_some_posts.find(:all)
    current_index = all_discussions.index(self)
    all_discussions[current_index + 1] # next discussion or nil
  end

  # see next_for
  def previous_for(user)
    all_discussions = user.discussions.find(:all)
    current_index = all_discussions.index(self)

    prev_index = current_index - 1
    # return the previous discussion or nil if current discussion is the first one
    prev_index >= 0 ? all_discussions[prev_index] : nil
  end

  def increment_unread_for!(user)
    relationships.for_user(user).try.increment!(:unread_count)
  end

  def unread_by?(user)
    relationships.for_user(user).unread_count > 0
  end

  # mark as either :read or :under
  def mark!(as, marking_user)
    relationships.for_user(marking_user).try.mark!(as)
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

  # 
  # returns the total number of pagination pages, given the pagination size.
  #
  def last_page(pagination_size=nil)
    pagination_size ||= Conf.pagination_size
    if posts_count > 0
      (posts_count.to_f / pagination_size.to_f).ceil
    else
      1
    end
  end

  def posts_changed
    @head_posts.try.clear
    update_attributes! :posts_count => visible_posts.count,
      :last_post => visible_posts.last,
      :replied_by => visible_posts.last.try.user,
      :replied_at => visible_posts.last.try.updated_at
    page.save if page
  end

end
