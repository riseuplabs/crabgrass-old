#  create_table "posts", :force => true do |t|
#    t.integer  "user_id",       :limit => 11
#    t.integer  "discussion_id", :limit => 11
#    t.text     "body"
#    t.text     "body_html"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#    t.datetime "deleted_at"
#    t.string   "type"
#  end

class Post < ActiveRecord::Base

  ##
  ## associations
  ##

  acts_as_rateable
  belongs_to :discussion
  belongs_to :user

  ##
  ## attributes
  ##

  format_attribute :body
  validates_presence_of :discussion, :user, :body  
  alias :created_by :user
  
  attr_accessor :in_reply_to    # the post this post was in reply to.
                                # it is tmp var used when post activities.

  attr_accessor :recipient      # for private posts, a tmp var to store who
                                # this post is being sent to. used by activities.

  ##
  ## methods
  ##

  # build a new post in memory, setting up the associations which need to be in
  # place, but don't save anything yet (however, if the page doesn't have a 
  # discussion record yet, then it is created and saved). Arg is a hash, with
  # these required keys: :user, :page, and :body. Afterwards, you must save the 
  # post, and the probably the page too, although it is not required.
  # In a non-page context, this method is not required: discussion.posts.build()
  # is sufficient.
  def self.build(options)
    raise ArgumentError.new unless options[:user] && options[:page] && options[:body]
    page = options.delete(:page)
    page.discussion ||= Discussion.create!(:page => page)
    post = page.discussion.posts.build(options)
    page.posts_count_will_change!
    return post
  end
 
  # used for default context, if present, to set for any embedded links
  def owner_name
    discussion.page.owner_name if discussion.page
  end

  # used for indexing
  def to_s
    "#{user} #{body}"
  end

  def editable_by?(user)
    user.id == self.user_id
  end

  def starred_by?(user)
    self.ratings.detect do |rating|
      rating.rating == 1 and rating.user_id == user.id
    end
  end
  
  protected

  def after_create
    discussion.update_attributes(:replied_by => self.user, :last_post => self,
      :replied_at => Time.now, :posts_count => discussion.posts_count+1)

    # none of these work, because the page we have here now is not the same
    # as the page object that the controller will be saving. Also, the save will
    # overwrite any increment_counter we do.
    # discussion.page.posts_count_will_change! if discussion.page
    # Page.increment_counter(:posts_count, discussion.page.id) if discussion.page
    # discussion.page.posts_count = discussion.posts_count if discussion.page
  end

  def after_destroy
    Discussion.decrement_counter(:posts_count, discussion.id)

    # not sure how to decrement the page.posts_count.
    #discussion.page.posts_count_will_change! if discussion.page
    #Page.decrement_count(:posts_count, discussion.page.id) if discussion.page
  end

end

