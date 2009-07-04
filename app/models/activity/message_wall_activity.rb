class MessageWallActivity < Activity
  include ActionView::Helpers::TagHelper

  validates_format_of :subject_type, :with => /User/
  validates_format_of :object_type, :with => /User/
  validates_presence_of :subject_id
  validates_presence_of :object_id
  validates_presence_of :extra

  serialize :extra

  alias_attr :user,     :subject
  alias_attr :author,   :object
  alias_attr :post_id,  :related_id

  def post=(post)
    self.post_id = post.id
    self.extra = {}
    self.extra[:snippet] = GreenCloth.new(post.body[0..140], 'page', [:lite_mode]).to_html
    self.extra[:snippet] += '...' if post.body.length > 140
    self.extra[:type] = 'status' if post.is_a? StatusPost
  end

  before_create :set_access
  def set_access
    # all content on the wall is public anyway
    self.access = Activity::PUBLIC
  end

  def description(view=nil)
    if extra[:type] == "status"
      txt = '{user} {message}' % {:user => user_span(:author), :message => extra[:snippet]}
    elsif user_id != author_id
      txt = '{author} wrote to {user}: {message}'[:activity_wall_message, {:user => user_span(:user), :author => user_span(:author), :message => content_tag(:span,extra[:snippet],:class => 'message')}]
    else
      txt = '{author} wrote: {message}'[:activity_message, {:author => user_span(:author), :message => content_tag(:span,extra[:snippet],:class => 'message')}]
    end
    if txt[-3..-1] == '...'
      @link = content_tag(:a, 'more'[:see_more_link], :href => "/messages/#{user_id}/show/#{post_id}")
    else
      @link = content_tag(:a, 'details'[:details_link], :href => "/messages/#{user_id}/show/#{post_id}")
    end
    return txt
  end

  def link
    @link
  end

  def icon
    if extra[:type] == 'status'
      'lightning'
    else
      'comment'
    end
  end

  def style
    url = '/avatars/%s/%s.jpg?%s' % [author.avatar_id||0, 'tiny', author.updated_at.to_i]
    "background-image: url(#{url});"
  end

end

