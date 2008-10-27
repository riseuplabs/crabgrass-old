class TwinkledActivity < Activity
  include ActionView::Helpers::TagHelper

  validates_format_of :subject_type, :with => /User/
  validates_format_of :object_type, :with => /User/
  validates_presence_of :subject_id
  validates_presence_of :object_id
  validates_presence_of :extra
  
  serialize :extra

  alias_attr :user,       :subject
  alias_attr :twinkler,   :object
  alias_attr :post,       :extra

  before_create :set_access
  def set_access
    self.access = Activity::PRIVATE
  end

  def description
    '{user} has starred your post "{post}"'[
       :activity_twinkled, 
       {:user => user_span(:twinkler), :post => post_span(post)}
    ]
  end

  def post_span(post)
    content_tag :a, h(post[:snippet]), :href => "/posts/jump/#{post[:id]}"
  end

  def icon
    'star'
  end

end

