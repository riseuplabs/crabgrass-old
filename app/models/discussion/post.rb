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
  extend PathFinder::FindByPath

  ##
  ## associations
  ##

  acts_as_rateable
  belongs_to :discussion
  belongs_to :user
  # if this is on a page we set page_terms so we can use path_finder
  belongs_to :page_terms

  after_create :update_discussion
  after_destroy :update_discussion

  ##
  ## named scopes
  ##

  named_scope :visible, :conditions => 'deleted_at IS NULL'

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
    post.page_terms = page.page_terms
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

  # These are currently only used from moderation mod.
  def delete
    update_attribute :deleted_at, Time.now
    update_discussion
  end

  def undelete
    update_attribute :deleted_at, nil
    update_discussion
  end

  # this should be able to be handled in the subclasses, but sometimes
  # when you create a new post, the subclass is not set yet.
  def public?
    ['Post', 'PublicPost', 'StatusPost'].include?(read_attribute(:type))
  end
  def private?
    'PrivatePost' == read_attribute(:type)
  end

  def default?
    false
  end

  def lite_html
    GreenCloth.new(self.body, 'page', [:lite_mode]).to_html
  end

  protected

  def update_discussion
    discussion.posts_changed
  end

end

