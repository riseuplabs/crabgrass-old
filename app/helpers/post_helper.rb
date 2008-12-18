module PostHelper

  def post_pagination_links
    content_tag(:tr, content_tag(:td, pagination_links(@posts, 'posts'), :colspan => 2)) if @posts.any?
  end

end
